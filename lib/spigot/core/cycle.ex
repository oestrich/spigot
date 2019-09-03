defmodule Spigot.Core.Cycle do
  @moduledoc """
  Core cycle

  Contains core commands of the game
  """

  use Spigot, :cycle

  alias Spigot.Core.CombatAction
  alias Spigot.Core.SayAction

  @impl true
  def actions() do
    [
      {CombatAction, [:vitals, :start, :stop, :tick]},
      {SayAction, [:broadcast, :receive]}
    ]
  end
end
