defmodule Spigot.Sessions.Foreman do
  @moduledoc """
  Session Foreman

  The in between process from `Spigot.Telnet.Server` and the rest of
  the processes. Starts the `Spigot.Sessions.Options` process on boot.
  """

  use GenServer

  alias Spigot.Sessions.Session

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = Enum.into(opts, %{})
    {:ok, state, {:continue, :init}}
  end

  def handle_continue(:init, state) do
    {:ok, state} = Session.start_options(state)
    {:ok, state} = Session.start_commands(state)
    {:noreply, state, {:continue, :login}}
  end

  def handle_continue(:login, state) do
    send(state.commands, :welcome)
    {:noreply, state}
  end

  def handle_info({:recv, :option, option}, state) do
    send(state.options, {:recv, option})
    {:noreply, state}
  end

  def handle_info({:recv, :text, data}, state) do
    send(state.commands, {:recv, data})
    {:noreply, state}
  end

  def handle_info({:send, data}, state) do
    send(state.protocol, {:send, data})
    {:noreply, state}
  end

  def handle_info(:terminate, state) do
    Session.terminate(state)
    {:noreply, state}
  end
end
