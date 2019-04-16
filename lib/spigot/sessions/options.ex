defmodule Spigot.Sessions.Options do
  @moduledoc """
  Process to parse telnet options from the client
  """

  use GenServer

  require Logger

  alias __MODULE__.OAuth

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{
      foreman: opts[:foreman],
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
    Logger.debug(fn ->
      "OAuth Start: #{inspect params}"
    end)

    state = OAuth.authorization_request(state, params)

    {:noreply, state}
  end

  defp process_option(state, _option), do: {:noreply, state}
end

defmodule Spigot.Sessions.Options.OAuth do
  use Spigot, :action

  def authorization_request(state, %{"host" => "grapevine.haus"}) do
    params = %{
      response_type: "code",
      client_id: "cb61f1cd-a8b8-445e-91b7-282bccbff890",
      scope: "profile email",
      state: UUID.uuid4()
    }

    render(state, view(), "authorization-request", %{params: params})
  end

  def authorization_request(_, _), do: :ok
end
