defmodule Spigot.Sessions.Commands do
  @moduledoc """
  Process to parse telnet options from the client
  """

  use GenServer

  alias Spigot.Router
  alias Spigot.View.Commands
  alias Spigot.View.Login

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

  def handle_info(:welcome, state) do
    send(state.foreman, {:send, Login.render("welcome", state)})
    send(state.foreman, {:send, Commands.render("prompt", state)})
    send(state.character, {:send, :vitals})

    {:noreply, state}
  end

  def handle_info({:recv, text}, state) do
    process_command(state, String.trim(text))
  end

  defp process_command(state, "") do
    {:noreply, state}
  end

  defp process_command(state, command_text) do
    conn = %Spigot.Conn{
      foreman: state.foreman,
      character: state.character,
      assigns: %{}
    }

    case Router.call(conn, command_text) do
      {:error, :unknown} ->
        send(state.foreman, {:send, Commands.render("unknown", %{})})
        send(state.foreman, {:send, Commands.render("prompt", %{})})
        {:noreply, state}

      result ->
        send(state.foreman, {:send, result.lines})
        {:noreply, state}
    end
  end
end

defmodule Spigot.Sessions.Commands.Combat do
  @moduledoc "Fake combat"

  use Spigot, :command

  def start(conn, _params) do
    send(conn.character, {:combat, :start})

    conn
    |> render("start")
    |> render(Commands, "prompt")
  end

  def stop(conn, _params) do
    send(conn.character, {:combat, :stop})

    conn
    |> render("stop")
    |> render(Commands, "prompt")
  end

  def tick(conn, _params) do
    send(conn.character, {:send, :vitals})

    conn
    |> render("tick")
    |> render(Commands, "prompt")
  end
end

defmodule Spigot.Sessions.Commands.Help do
  @moduledoc "View help"

  use Spigot, :command

  def base(conn, _params) do
    conn
    |> render("base")
    |> render(Commands, "prompt")
  end

  def topic(conn, params) do
    base(conn, params)
  end
end

defmodule Spigot.Sessions.Commands.Quit do
  @moduledoc "Terminate your session"

  use Spigot, :command

  def base(conn, _params) do
    send(conn.foreman, :stop)
    render(conn, "goodbye")
  end
end

defmodule Spigot.Sessions.Commands.Say do
  @moduledoc "Say a message"

  use Spigot, :command

  def base(conn, %{"message" => text}) do
    conn
    |> render("text", %{text: text})
    |> render(Commands, "prompt")
  end
end

defmodule Spigot.Sessions.Commands.Vitals do
  @moduledoc "Terminate your session"

  use Spigot, :command

  def base(conn, _params) do
    send(conn.character, {:send, :vitals})

    conn
    |> push("Sending vitals...\n")
    |> render(Commands, "prompt")
  end
end
