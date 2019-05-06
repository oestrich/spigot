defmodule Spigot.Core.WhoCommand do
  @moduledoc """
  View other players in the game
  """

  use Spigot, :command

  alias Engine.Players

  @doc """
  View other players
  """
  def base(conn, _params) do
    players =
      Enum.map(Players.online(), fn {_pid, character} ->
        character
      end)

    conn
    |> render("who", %{players: players})
    |> render(CommandsView, "prompt")
  end
end
