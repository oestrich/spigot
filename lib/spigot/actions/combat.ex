defmodule Spigot.Actions.Combat do
  @moduledoc """
  Combat

  Starts a tick that will send fake vital updates to the client,
  pretending to be in combat with something.
  """

  use Spigot, :action

  alias Spigot.Views.Combat
  alias Spigot.Views.Vitals

  @delay 1000

  def vitals(state, _params) do
    render(state, Vitals, "vitals", state)
  end

  def start(state, params) do
    state
    |> Map.put(:combat, true)
    |> tick(params)
  end

  def stop(state, _params) do
    Map.put(state, :combat, false)
  end

  def tick(state = %{combat: true}, params) do
    Process.send_after(self(), %__MODULE__{action: :tick, params: params}, @delay)
    state = adjust_vitals(state)

    state
    |> vitals(params)
    |> render(Combat, "tick", state)
  end

  def tick(state, _params), do: state

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
