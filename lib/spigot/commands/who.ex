defmodule Spigot.Commands.Who do
  @moduledoc "View other players in the game"

  use Spigot, :command

  def base(conn, _params) do
    conn
    |> render("who")
    |> render(Commands, "prompt")
  end
end
