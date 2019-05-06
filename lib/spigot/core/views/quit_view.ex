defmodule Spigot.Core.QuitView do
  use Spigot, :view

  def render("goodbye", _assigns) do
    "Goodbye!\n"
  end
end
