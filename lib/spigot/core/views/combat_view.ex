defmodule Spigot.Core.CombatView do
  use Spigot, :view

  def render("start", _assigns) do
    "Starting combat\n"
  end

  def render("stop", _assigns) do
    "Stopping combat\n"
  end

  def render("tick", _assigns) do
    """
    You attack the #{IO.ANSI.yellow()}enemy#{IO.ANSI.reset()}.
    The #{IO.ANSI.yellow()}enemy#{IO.ANSI.reset()} attacks you.
    """
  end
end
