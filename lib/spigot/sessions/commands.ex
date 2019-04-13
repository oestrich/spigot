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
  alias Spigot.Messages

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
    send(state.foreman, {:send, Messages.Welcome.call(state)})
    send(state.foreman, {:send, Messages.Prompt.call(state)})
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
        send(state.foreman, {:send, Messages.Unknown.call(state)})
        send(state.foreman, {:send, Messages.Prompt.call(state)})
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

defmodule Spigot.Command do
  @moduledoc """
  Behaviour for commands
  """

  @callback command() :: String.t()

  @callback call(map(), list()) :: {:noreply, map()}
end

defmodule Spigot.Sessions.Commands.Help do
  @moduledoc "View help"

  @behaviour Spigot.Command

  alias Spigot.Messages

  def command(), do: "help"

  def call(state, _args) do
    send(state.foreman, {:send, Messages.Help.Base.call(state)})
    send(state.foreman, {:send, Messages.Prompt.call(state)})
    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Commands.Quit do
  @moduledoc "Terminate your session"

  @behaviour Spigot.Command

  alias Spigot.Messages

  def command(), do: "quit"

  def call(state, _args) do
    send(state.foreman, {:send, Messages.Goodbye.call(state)})
    send(state.foreman, :stop)
    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Commands.Say do
  @moduledoc "Say a message"

  @behaviour Spigot.Command

  alias Spigot.Messages

  def command(), do: "say"

  def call(state, text) do
    text = Enum.join(text, " ")
    send(state.foreman, {:send, Messages.Say.call(state, [text])})
    send(state.foreman, {:send, Messages.Prompt.call(state)})
    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Commands.Vitals do
  @moduledoc "Terminate your session"

  @behaviour Spigot.Command

  alias Spigot.Messages

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

    send(state.foreman, {:send, "Sending vitals...\n"})
    send(state.foreman, {:send, Messages.Prompt.call(state)})
    send(state.foreman, {:send, Messages.Character.Vitals.call(state)})

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
