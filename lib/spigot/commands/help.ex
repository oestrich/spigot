defmodule Spigot.Commands.Help do
  @moduledoc "View help"

  use Spigot, :command

  def base(conn, _params) do
    conn
    |> render("base")
    |> render(Commands, "prompt")
  end

  def topic(conn, params) do
    base(conn, params)
  end
end
