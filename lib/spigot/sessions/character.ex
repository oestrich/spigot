defmodule Spigot.Sessions.Character do
  @moduledoc """
  Session Character

  A simple process to manage character actions
  """

  use Spigot, :sink

  alias Spigot.Actions.Combat
  alias Spigot.Character

  actions(Combat, [:vitals, :start, :stop, :tick])

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
end
