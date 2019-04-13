defmodule Spigot.Sessions.Options do
  @moduledoc """
  Process to parse telnet options from the client
  """

  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{
      foreman: opts[:foreman],
      gmcp: false
    }

    {:ok, state}
  end

  def handle_info({:recv, option}, state) do
    process_option(state, option)
  end

  defp process_option(state, {:gmcp, "Core.Hello", data}) do
    Logger.info("Client says hello #{data["client"]}")
    {:noreply, state}
  end

  defp process_option(state, {:gmcp, "Core.Supports.Set", data}) do
    state = Map.put(state, :supports, data)
    {:noreply, state}
  end

  defp process_option(state, {:do, :gmcp}) do
    Logger.info("GMCP enabled")
    state = Map.put(state, :gmcp, true)
    {:noreply, state}
  end

  defp process_option(state, {:do, byte}) do
    Logger.debug(fn ->
      "Trying to DO #{byte}"
    end)

    {:noreply, state}
  end

  defp process_option(state, {:will, byte}) do
    Logger.debug(fn ->
      "Trying to WILL #{byte}"
    end)

    {:noreply, state}
  end

  defp process_option(state, _option), do: {:noreply, state}
end
