defmodule Engine.Listener do
  @moduledoc """
  Process that starts the `ranch` listener
  """

  use GenServer

  require Logger

  alias Engine.Telnet.Server

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

    case :ranch.start_listener({__MODULE__, :tcp}, :ranch_tcp, opts, Server, []) do
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

    case :ranch.start_listener({__MODULE__, :tls}, :ranch_ssl, opts, Server, []) do
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
