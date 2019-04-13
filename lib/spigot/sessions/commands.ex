defmodule Spigot.Sessions.Commands do
  @moduledoc """
  Process to parse telnet options from the client
  """

  use GenServer

  require Logger

  alias __MODULE__.Quit
  alias __MODULE__.Say
  alias __MODULE__.Vitals
  alias Spigot.Messages

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{
      foreman: opts[:foreman],
      vitals: %{
        health_points: 50,
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

  defp process_command(state, "quit") do
    Quit.call(state, [])
  end

  defp process_command(state, "say " <> text) do
    Say.call(state, [text])
  end

  defp process_command(state, "vitals") do
    Vitals.call(state, [])
  end

  defp process_command(state, _text) do
    send(state.foreman, {:send, Messages.Unknown.call(state)})
    send(state.foreman, {:send, Messages.Prompt.call(state)})
    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Commands.Quit do
  @moduledoc "Terminate your session"

  alias Spigot.Messages

  def call(state, _args) do
    send(state.foreman, {:send, Messages.Goodbye.call(state)})
    send(state.foreman, :stop)
    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Commands.Say do
  @moduledoc "Say a message"

  alias Spigot.Messages

  def call(state, [text]) do
    send(state.foreman, {:send, Messages.Say.call(state, [text])})
    send(state.foreman, {:send, Messages.Prompt.call(state)})
    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Commands.Vitals do
  @moduledoc "Terminate your session"

  alias Spigot.Messages

  def call(state, _args) do
    send(state.foreman, {:send, Messages.Character.Vitals.call(state)})
    {:noreply, state}
  end
end
