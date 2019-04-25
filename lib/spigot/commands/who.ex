defmodule Spigot.Commands.Who do
  @moduledoc """
  View other players in the game
  """

  use Spigot, :command

  @doc """
  View other players
  """
  def base(conn, _params) do
    conn
    |> render("who")
    |> render(Commands, "prompt")
  end
end
