defmodule Spigot.Views.Quit do
  use Spigot, :view

  def render("goodbye", _assigns) do
    "Goodbye!\n"
  end
end
