defmodule Spigot.Telnet.Server do
  @moduledoc """
  ranch protocol for handling telnet connection
  """

  alias Spigot.Sessions
  alias Spigot.Telnet.Options

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
      buffer: <<>>
    }

    :gen_server.enter_loop(__MODULE__, [], state)
  end

  def handle_info(:init, state) do
    {:ok, foreman} = Sessions.start(self())
    state = Map.put(state, :foreman, foreman)
    {:noreply, state, {:continue, :initial_iacs}}
  end

  def handle_info({:tcp, _socket, data}, state) do
    process_data(state, data)
  end

  def handle_info({:tcp_closed, _socket}, state) do
    send(state.foreman, :terminate)
    {:stop, :normal, state}
  end

  def handle_info({:send, data}, state) do
    state.transport.send(state.socket, data)
    {:noreply, state}
  end

  def handle_continue(:initial_iacs, state) do
    state.transport.send(state.socket, <<255, 251, 201>>)
    {:noreply, state}
  end

  defp process_data(state, data) do
    {options, string, buffer} = Options.parse(state.buffer <> data)
    state = %{state | buffer: buffer}

    Enum.each(options, fn option ->
      send(state.foreman, {:recv, :option, option})
    end)

    send(state.foreman, {:recv, :text, string})

    {:noreply, state}
  end
end
