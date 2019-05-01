defmodule Engine.Sessions.Commands do
  @moduledoc """
  Process to parse telnet options from the client
  """

  use GenServer

  alias Spigot.Actions.Combat
  alias Spigot.Router
  alias Spigot.Views.Commands
  alias Spigot.Views.Login

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{
      foreman: opts[:foreman],
      character: opts[:character]
    }

    {:ok, state}
  end

  def handle_info({:welcome, username}, state) do
    send(state.foreman, {:send, Login.render("logged-in", %{username: username})})
    send(state.foreman, {:send, Commands.render("prompt", state)})
    send(state.character, %Combat{action: :vitals, params: %{}})

    {:noreply, state}
  end

  def handle_info({:recv, text}, state) do
    process_command(state, String.trim(text))
  end

  defp process_command(state, "") do
    {:noreply, state}
  end

  defp process_command(state, command_text) do
    conn = %Engine.Conn{
      foreman: state.foreman,
      character: state.character,
      assigns: %{}
    }

    case Router.call(conn, command_text) do
      {:error, :unknown} ->
        send(state.foreman, {:send, Commands.render("unknown", %{})})
        send(state.foreman, {:send, Commands.render("prompt", %{})})
        {:noreply, state}

      conn ->
        send(state.foreman, {:send, conn.lines})

        Enum.each(conn.messages, fn message ->
          forward(state, message)
        end)

        {:noreply, state}
    end
  end

  defp forward(state, {:character, message}) do
    send(state.character, message)
  end

  defp forward(state, {:foreman, message}) do
    send(state.foreman, message)
  end
end
