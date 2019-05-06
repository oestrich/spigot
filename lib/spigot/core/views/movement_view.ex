defmodule Spigot.Core.MovementView do
  use Spigot, :view

  def render("base", _assigns) do
    "No such exit.\n"
  end
end
