defmodule Spigot.Sessions.Character do
  @moduledoc """
  Session Character

  A simple process to manage character actions
  """

  use GenServer

  require Logger

  import Spigot.Action

  alias __MODULE__.Combat
  alias Spigot.Character
  alias Spigot.View.Vitals

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{
      foreman: opts[:foreman],
      combat: false,
      vitals: %Character.Vitals{
        health_points: 40,
        max_health_points: 55,
        skill_points: 35,
        max_skill_points: 55,
        endurance_points: 45,
        max_endurance_points: 55,
      }
    }

    {:ok, state}
  end

  def handle_info({:send, :vitals}, state) do
    render(state, Vitals, "vitals", %{vitals: state.vitals})
    {:noreply, state}
  end

  def handle_info({:combat, :start}, state) do
    process_action(state, &Combat.start/1)
  end

  def handle_info({:combat, :stop}, state) do
    process_action(state, &Combat.stop/1)
  end

  def handle_info({:combat, :tick}, state) do
    process_action(state, &Combat.tick/1)
  end

  defp process_action(state, fun) do
    state = fun.(state)
    {:noreply, state}
  end
end

defmodule Spigot.Sessions.Character.Combat do
  @moduledoc """
  Combat

  Starts a tick that will send fake vital updates to the client,
  pretending to be in combat with something.
  """

  use Spigot, :action

  alias Spigot.View.Combat
  alias Spigot.View.Vitals

  @delay 1000

  def start(state) do
    state
    |> Map.put(:combat, true)
    |> tick()
  end

  def stop(state) do
    Map.put(state, :combat, false)
  end

  def tick(state = %{combat: true}) do
    Process.send_after(self(), {:combat, :tick}, @delay)
    state = adjust_vitals(state)

    state
    |> render(Vitals, "vitals", state)
    |> render(Combat, "tick", state)
  end

  def tick(state), do: state

  def adjust_vitals(state) do
    state
    |> adjust_vital(:health_points, :max_health_points)
    |> adjust_vital(:skill_points, :max_skill_points)
    |> adjust_vital(:endurance_points, :max_endurance_points)
  end

  def adjust_vital(state, key, max_key) do
    change = :rand.uniform(20) - 10
    points = Map.get(state.vitals, key) + change
    points = Enum.min([points, Map.get(state.vitals, max_key)])
    points = Enum.max([points, 0])

    vitals = Map.put(state.vitals, key, points)
    Map.put(state, :vitals, vitals)
  end
end
