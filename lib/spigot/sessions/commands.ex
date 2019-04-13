defmodule Spigot.Sessions.Commands do
  @moduledoc """
  Process to parse telnet options from the client
  """

  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{foreman: opts[:foreman]}
    {:ok, state}
  end

  def handle_info(:welcome, state) do
    send(state.foreman, {:send, "Welcome to " <> IO.ANSI.cyan() <> "Spigot.\n" <> IO.ANSI.reset()})
    send(state.foreman, {:send, "> "})
    {:noreply, state}
  end

  def handle_info({:recv, text}, state) do
    process_command(state, text)
  end

  defp process_command(state, "") do
    {:noreply, state}
  end

  defp process_command(state, text) do
    send(state.foreman, {:send, text})
    send(state.foreman, {:send, "> "})
    {:noreply, state}
  end
end
