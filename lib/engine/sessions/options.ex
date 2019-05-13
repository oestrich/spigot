defmodule Engine.Sessions.Options do
  @moduledoc """
  Process to parse telnet options from the client
  """

  use GenServer

  require Logger

  alias Engine.Sessions.Auth.OAuth

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{
      foreman: opts[:foreman],
      auth: opts[:auth],
      new_environ: false,
      oauth: false,
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

  defp process_option(state, {:dont, byte}) do
    Logger.debug(fn ->
      "DONT #{byte}"
    end)

    {:noreply, state}
  end

  defp process_option(state, {:will, :oauth}) do
    Logger.info("Starting OAuth")
    state = Map.put(state, :oauth, true)
    {:noreply, state}
  end

  defp process_option(state, {:will, :new_environ}) do
    send(state.foreman, {:send, <<255, 250, 39, 1, 0>> <> "IPADDRESS" <> <<255, 240>>})
    state = Map.put(state, :new_environ, true)
    {:noreply, state}
  end

  defp process_option(state, {:will, byte}) do
    Logger.debug(fn ->
      "Trying to WILL #{byte}"
    end)

    {:noreply, state}
  end

  defp process_option(state, {:wont, byte}) do
    Logger.debug(fn ->
      "WONT #{byte}"
    end)

    {:noreply, state}
  end

  defp process_option(state, {:oauth, "Start", params}) do
    send(state.auth, %OAuth{action: :authorization_request, params: params})
    {:noreply, state}
  end

  defp process_option(state, {:oauth, "AuthorizationGrant", params}) do
    send(state.auth, %OAuth{action: :authorization_grant, params: params})
    {:noreply, state}
  end

  defp process_option(state, {:new_environ, :is, values}) do
    Logger.info("New environ is: #{inspect(values)}")
    {:noreply, state}
  end

  defp process_option(state, _option), do: {:noreply, state}
end
