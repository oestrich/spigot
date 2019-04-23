defmodule Spigot.Commands.Quit do
  @moduledoc """
  Terminate your session
  """

  use Spigot, :command

  def base(conn, _params) do
    conn
    |> render("goodbye")
    |> forward(:foreman, :stop)
  end
end
