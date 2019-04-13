defmodule Spigot.Sessions.Commands do
  @moduledoc """
  Process to parse telnet options from the client
  """

  use GenServer

  require Logger

  alias __MODULE__.Help
  alias __MODULE__.Quit
  alias __MODULE__.Say
  alias __MODULE__.Vitals
  alias Spigot.Sessions.Views.Commands
  alias Spigot.Sessions.Views.Login

  @modules [Help, Quit, Say, Vitals]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{
      foreman: opts[:foreman],
      vitals: %{
        health_points: 40,
        max_health_points: 55
      }
    }

    {:ok, state}
  end

  def handle_info(:welcome, state) do
    send(state.foreman, {:send, Login.render("welcome", state)})
    send(state.foreman, {:send, Commands.render("prompt", state)})
    {:noreply, state}
  end

  def handle_info({:recv, text}, state) do
    process_command(state, String.trim(text))
  end

  defp process_command(state, "") do
    {:noreply, state}
  end

  defp process_command(state, text) do
    [command | text] = String.split(text, " ")

    with {:ok, module} <- find_module(command) do
      module.call(state, text)
    else
      {:error, :unknown} ->
        send(state.foreman, {:send, Commands.render("unknown", state)})
        send(state.foreman, {:send, Commands.render("prompt", state)})
        {:noreply, state}
    end
  end

  defp find_module(command) do
    module =
      Enum.find(@modules, fn module ->
        module.command() == command
      end)

    case module != nil do
      true ->
        {:ok, module}

      false ->
        {:error, :unknown}
    end
  end
end

defmodule Spigot.Sessions.Commands.Help do
  @moduledoc "View help"

  use Spigot.Command

  alias Spigot.Sessions.Views.Commands

  def command(), do: "help"

  def call(state, _args) do
    push(state, render("base", state))
    push(state, render(Commands, "prompt", state))

    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Commands.Quit do
  @moduledoc "Terminate your session"

  use Spigot.Command

  def command(), do: "quit"

  def call(state, _args) do
    push(state, render("goodbye", state))
    send(state.foreman, :stop)

    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Commands.Say do
  @moduledoc "Say a message"

  use Spigot.Command

  alias Spigot.Sessions.Views.Commands

  def command(), do: "say"

  def call(state, text) do
    text = Enum.join(text, " ")

    push(state, render("text", %{text: text}))
    push(state, render(Commands, "prompt", state))

    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Commands.Vitals do
  @moduledoc "Terminate your session"

  use Spigot.Command

  alias Spigot.Sessions.Views.Commands

  @delay 1000

  def command(), do: "vitals"

  def call(state, [count]) do
    count = String.to_integer(count)

    Enum.each(1..count, fn i ->
      Process.send_after(self(), {:recv, "vitals"}, @delay * i)
    end)

    {:noreply, state}
  end

  def call(state, _args) do
    state = adjust_vitals(state)

    push(state, "Sending vitals...\n")
    push(state, render("vitals", state))
    push(state, render(Commands, "prompt", state))

    {:noreply, state}
  end

  def adjust_vitals(state) do
    change = :rand.uniform(20) - 10
    health_points = state.vitals.health_points + change
    health_points = Enum.min([health_points, state.vitals.max_health_points])
    vitals = Map.put(state.vitals, :health_points, health_points)
    Map.put(state, :vitals, vitals)
  end
end
