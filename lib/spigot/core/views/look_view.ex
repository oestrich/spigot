defmodule Spigot.Core.LookView do
  use Spigot, :view

  def render("base", _assigns) do
    "You are in a void.\n"
  end
end
