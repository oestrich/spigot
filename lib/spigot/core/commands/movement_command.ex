defmodule Spigot.Core.MovementCommand do
  @moduledoc """
  Look at your surroundings
  """

  use Spigot, :command

  @doc """
  Move north
  """
  def north(conn, _params) do
    conn
    |> render("base")
    |> render(CommandsView, "prompt")
  end

  @doc """
  Move south
  """
  def south(conn, _params) do
    conn
    |> render("base")
    |> render(CommandsView, "prompt")
  end

  @doc """
  Move east
  """
  def east(conn, _params) do
    conn
    |> render("base")
    |> render(CommandsView, "prompt")
  end

  @doc """
  Move west
  """
  def west(conn, _params) do
    conn
    |> render("base")
    |> render(CommandsView, "prompt")
  end
end
