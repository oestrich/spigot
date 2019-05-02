defmodule Spigot.Commands.Look do
  @moduledoc """
  Look at your surroundings
  """

  use Spigot, :command

  @doc """
  Look at the room you're in
  """
  def base(conn, _params) do
    conn
    |> render("base")
    |> render(Commands, "prompt")
  end
end
