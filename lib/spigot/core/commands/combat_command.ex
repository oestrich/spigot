defmodule Spigot.Core.CombatCommand do
  @moduledoc """
  Fake combat
  """

  use Spigot, :command

  alias Spigot.Core.CombatAction

  def start(conn, _params) do
    conn
    |> render("start")
    |> render(CommandsView, "prompt")
    |> event(:character, CombatAction, :start)
  end

  def stop(conn, _params) do
    conn
    |> render("stop")
    |> render(CommandsView, "prompt")
    |> event(:character, CombatAction, :stop)
  end

  def tick(conn, _params) do
    conn
    |> render("tick")
    |> render(CommandsView, "prompt")
    |> event(:character, CombatAction, :vitals)
  end
end
