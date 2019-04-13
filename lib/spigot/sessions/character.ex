defmodule Spigot.Sessions.Character do
  @moduledoc """
  Session Character

  A simple process to manage character actions
  """

  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{
      foreman: opts[:foreman]
    }

    {:ok, state}
  end

  def handle_info({:combat, :start}, state) do
    Logger.debug("Starting combat")
    {:noreply, state}
  end

  def handle_info({:combat, :stop}, state) do
    Logger.debug("Stopping combat")
    {:noreply, state}
  end
end
