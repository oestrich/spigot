defmodule Spigot.Core.Bottle do
  @moduledoc """
  Core bottle

  Contains core commands of the game
  """

  use Spigot, :bottle

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
