defmodule Engine.Listener do
  @moduledoc """
  Process that starts the `ranch` listener
  """

  use GenServer

  require Logger

  alias Engine.Listener.Protocol

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, %{}, {:continue, :listen_tcp}}
  end

  def handle_continue(:listen_tcp, state) do
    opts = %{
      socket_opts: [{:port, 4444}],
      max_connections: 4096
    }

    case :ranch.start_listener({__MODULE__, :tcp}, :ranch_tcp, opts, Protocol, []) do
      {:ok, listener} ->
        set_listener(state, listener)

      {:error, {:already_started, listener}} ->
        set_listener(state, listener)
    end
  end

  def handle_continue(:listen_tls, state) do
    opts = %{
      socket_opts: [{:port, 4443}, {:keyfile, keyfile()}, {:certfile, certfile()}],
      max_connections: 4096
    }

    case :ranch.start_listener({__MODULE__, :tls}, :ranch_ssl, opts, Protocol, []) do
      {:ok, listener} ->
        set_tls_listener(state, listener)

      {:error, {:already_started, listener}} ->
        set_tls_listener(state, listener)
    end
  end

  defp keyfile() do
    case Application.get_env(:spigot, :listener)[:keyfile] do
      nil ->
        Path.join(:code.priv_dir(:spigot), "certs/key.pem")

      keyfile ->
        keyfile
    end
  end

  defp certfile() do
    case Application.get_env(:spigot, :listener)[:certfile] do
      nil ->
        Path.join(:code.priv_dir(:spigot), "certs/cert.pem")

      certfile ->
        certfile
    end
  end

  defp set_listener(state, listener) do
    Logger.info("Telnet Listener Started")

    state = Map.put(state, :listener, listener)

    case Application.get_env(:spigot, :listener)[:tls] do
      true ->
        {:noreply, state, {:continue, :listen_tls}}

      false ->
        {:noreply, state}
    end
  end

  defp set_tls_listener(state, listener) do
    Logger.info("TLS Listener Started")
    state = Map.put(state, :tls_listener, listener)
    {:noreply, state}
  end
end

defmodule Engine.Listener.Protocol do
  @moduledoc """
  ranch protocol for handling telnet connection
  """

  alias Engine.Conn.Event
  alias Engine.Conn.Prompt
  alias Engine.Sessions
  alias Telnet.Options

  require Logger

  @behaviour :ranch_protocol

  @impl true
  def start_link(ref, _socket, transport, opts) do
    # Use the special start link to get around a ranch deadlock
    # on `:ranch.handshake/1`
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, transport, opts])
    {:ok, pid}
  end

  @doc false
  def init(ref, transport, _opts) do
    # See deadlock comment above
    {:ok, socket} = :ranch.handshake(ref)
    :ok = transport.setopts(socket, active: true)
    send(self(), :init)

    state = %{
      socket: socket,
      transport: transport,
      buffer: <<>>,
      options: %{
        newline: false
      }
    }

    :gen_server.enter_loop(__MODULE__, [], state)
  end

  def handle_info(:init, state) do
    {:ok, foreman} = Sessions.start(self())
    state = Map.put(state, :foreman, foreman)
    {:noreply, state, {:continue, :initial_iacs}}
  end

  def handle_info({:takeover, foreman}, state) do
    state = Map.put(state, :foreman, foreman)
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, data}, state) do
    process_data(state, data)
  end

  def handle_info({:ssl, _socket, data}, state) do
    process_data(state, data)
  end

  def handle_info({:tcp_closed, _socket}, state) do
    handle_info(:terminate, state)
  end

  def handle_info({:ssl_closed, _socket}, state) do
    handle_info(:terminate, state)
  end

  def handle_info(:terminate, state) do
    Logger.info("Session terminating")
    send(state.foreman, :terminate)
    {:stop, :normal, state}
  end

  def handle_info({:send, data}, state) do
    data = List.wrap(data)

    state =
      Enum.reduce(data, state, fn data, state ->
        push(state, data, %{})
      end)

    {:noreply, state}
  end

  def handle_info({:send, data, opts}, state) do
    data = List.wrap(data)

    state =
      Enum.reduce(data, state, fn data, state ->
        push(state, data, opts)
      end)

    {:noreply, state}
  end

  def handle_continue(:initial_iacs, state) do
    # WILL GMCP
    state.transport.send(state.socket, <<255, 251, 201>>)
    # DO OAuth
    state.transport.send(state.socket, <<255, 253, 165>>)
    # DO NEW-ENVIRON
    state.transport.send(state.socket, <<255, 253, 39>>)
    {:noreply, state}
  end

  defp push(state, output = %Event{type: :game}, _opts) do
    data = <<255, 250, 201>>
    data = data <> output.topic <> " "
    data = data <> Jason.encode!(output.data)
    data = data <> <<255, 240>>

    state.transport.send(state.socket, data)
    state
  end

  defp push(state, output = %Event{type: :oauth}, _opts) do
    data = <<255, 250, 165>>
    data = data <> output.topic <> " "
    data = data <> Jason.encode!(output.data)
    data = data <> <<255, 240>>

    state.transport.send(state.socket, data)
    state
  end

  defp push(state, %Prompt{text: data}, _opts) do
    push_text(state, data)
    state.transport.send(state.socket, <<255, 249>>)
    update_newline(state, true)
  end

  defp push(state, data, %{ga: true}) when is_binary(data) do
    push_text(state, data)
    state.transport.send(state.socket, <<255, 249>>)
    update_newline(state, false)
  end

  defp push(state, data, _opts) do
    push_text(state, data)
    update_newline(state, false)
  end

  defp push_text(state, text) do
    case state.options.newline do
      true ->
        state.transport.send(state.socket, ["\n", text])

      false ->
        state.transport.send(state.socket, text)
    end
  end

  defp process_data(state, data) do
    {options, string, buffer} = Options.parse(state.buffer <> data)
    state = %{state | buffer: buffer}

    Enum.each(options, fn option ->
      send(state.foreman, {:recv, :option, option})
    end)

    send(state.foreman, {:recv, :text, string})

    {:noreply, update_newline(state, String.length(string) == 0)}
  end

  defp update_newline(state, status) do
    %{state | options: %{state.options | newline: status}}
  end
end
