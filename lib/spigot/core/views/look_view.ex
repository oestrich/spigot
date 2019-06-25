defmodule Spigot.Core.LookView do
  use Spigot, :view

  def render("base", _assigns) do
    "You are in a void, there is nothing around you.\n"
  end
end
