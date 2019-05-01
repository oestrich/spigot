defmodule Spigot.Commands.Who do
  @moduledoc """
  View other players in the game
  """

  use Spigot, :command

  alias Engine.Players

  @doc """
  View other players
  """
  def base(conn, _params) do
    conn
    |> render("who", %{players: Players.online()})
    |> render(Commands, "prompt")
  end
end
