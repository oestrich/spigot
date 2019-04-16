defmodule Spigot.Commands.Combat do
  @moduledoc "Fake combat"

  use Spigot, :command

  def start(conn, _params) do
    conn
    |> render("start")
    |> render(Commands, "prompt")
    |> forward(:character, {:combat, :start})
  end

  def stop(conn, _params) do
    conn
    |> render("stop")
    |> render(Commands, "prompt")
    |> forward(:character, {:combat, :stop})
  end

  def tick(conn, _params) do
    conn
    |> render("tick")
    |> render(Commands, "prompt")
    |> forward(:character, {:send, :vitals})
  end
end
