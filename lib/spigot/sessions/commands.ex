defmodule Spigot.Sessions.Commands do
  @moduledoc """
  Process to parse telnet options from the client
  """

  use GenServer

  alias Spigot.Router
  alias Spigot.Sessions.Views.Commands
  alias Spigot.Sessions.Views.Login

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{
      foreman: opts[:foreman],
      character: opts[:character],
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
    case Router.call(state, text) do
      {:error, :unknown} ->
        send(state.foreman, {:send, Commands.render("unknown", state)})
        send(state.foreman, {:send, Commands.render("prompt", state)})
        {:noreply, state}

      result ->
        result
    end
  end
end

defmodule Spigot.Sessions.Commands.Combat do
  @moduledoc "Fake combat"

  use Spigot, :command

  alias Spigot.Sessions.Commands.Vitals

  def start(state, _) do
    push(state, render("start", state))
    push(state, render(Commands, "prompt", state))
    send(state.character, {:combat, :start})

    {:noreply, state}
  end

  def stop(state, _) do
    push(state, render("stop", state))
    push(state, render(Commands, "prompt", state))
    send(state.character, {:combat, :stop})

    {:noreply, state}
  end

  def tick(state, _) do
    state = Vitals.adjust_vitals(state)

    push(state, render("tick", state))
    push(state, render(Commands, "prompt", state))

    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Commands.Help do
  @moduledoc "View help"

  use Spigot, :command

  def base(state, _) do
    push(state, render("base", state))
    push(state, render(Commands, "prompt", state))

    {:noreply, state}
  end

  def topic(state, _topic) do
    base(state, [])
  end
end

defmodule Spigot.Sessions.Commands.Quit do
  @moduledoc "Terminate your session"

  use Spigot, :command

  def base(state, _) do
    push(state, render("goodbye", state))
    send(state.foreman, :stop)

    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Commands.Say do
  @moduledoc "Say a message"

  use Spigot, :command

  def base(state, %{"message" => text}) do
    push(state, render("text", %{text: text}))
    push(state, render(Commands, "prompt", state))

    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Commands.Vitals do
  @moduledoc "Terminate your session"

  use Spigot, :command

  @delay 1000

  def base(state, _) do
    state = adjust_vitals(state)

    push(state, "Sending vitals...\n")
    push(state, render("vitals", state))
    push(state, render(Commands, "prompt", state))

    {:noreply, state}
  end

  def count(state, %{"count" => count}) do
    count = String.to_integer(count)

    Enum.each(1..count, fn i ->
      Process.send_after(self(), {:recv, "vitals"}, @delay * i)
    end)

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
