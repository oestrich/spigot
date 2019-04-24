defmodule Spigot.Commands.Quit do
  @moduledoc """
  Terminate your session
  """

  use Spigot, :command

  @doc """
  Sign out
  """
  def base(conn, _params) do
    conn
    |> render("goodbye")
    |> forward(:foreman, :stop)
  end
end
