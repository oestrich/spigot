defmodule Spigot.Listener do
  @moduledoc """
  Process that starts the `ranch` listener
  """

  use GenServer

  alias Spigot.Telnet.Server

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, %{}, {:continue, :listen}}
  end

  def handle_continue(:listen, state) do
    opts = %{
      socket_opts: [{:port, 4444}],
      max_connections: 4096
    }

    case :ranch.start_listener(__MODULE__, :ranch_tcp, opts, Server, []) do
      {:ok, listener} ->
        set_listener(state, listener)

      {:error, {:already_started, listener}} ->
        set_listener(state, listener)
    end
  end

  defp set_listener(state, listener) do
    state = Map.put(state, :listener, listener)
    {:noreply, state}
  end
end
