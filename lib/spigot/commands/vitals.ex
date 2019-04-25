defmodule Spigot.Commands.Vitals do
  @moduledoc """
  Re-send your vitals
  """

  use Spigot, :command

  alias Spigot.Actions.Combat

  @doc """
  Send a vitals GMCP message
  """
  def base(conn, _params) do
    conn
    |> push("Sending vitals...\n")
    |> render(Commands, "prompt")
    |> event(:character, Combat, :vitals)
  end
end
