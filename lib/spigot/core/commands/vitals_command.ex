defmodule Spigot.Core.VitalsCommand do
  @moduledoc """
  Re-send your vitals
  """

  use Spigot, :command

  alias Spigot.Core.CombatAction

  @doc """
  Send a vitals GMCP message
  """
  def base(conn, _params) do
    conn
    |> push("Sending vitals...\n")
    |> render(CommandsView, "prompt")
    |> event(:character, CombatAction, :vitals)
  end
end
