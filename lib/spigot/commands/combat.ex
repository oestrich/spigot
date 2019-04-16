defmodule Spigot.Commands.Combat do
  @moduledoc "Fake combat"

  use Spigot, :command

  alias Spigot.Actions.Combat

  def start(conn, _params) do
    conn
    |> render("start")
    |> render(Commands, "prompt")
    |> event(:character, Combat, :start)
  end

  def stop(conn, _params) do
    conn
    |> render("stop")
    |> render(Commands, "prompt")
    |> event(:character, Combat, :stop)
  end

  def tick(conn, _params) do
    conn
    |> render("tick")
    |> render(Commands, "prompt")
    |> event(:character, Combat, :vitals)
  end
end
