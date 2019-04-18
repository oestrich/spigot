defmodule Spigot.Views.Login do
  use Spigot, :view

  def render("logged-in", _assigns) do
    "Welcome to #{IO.ANSI.cyan()}Spigot.#{IO.ANSI.reset()}\n"
  end

  def render("welcome", _assigns) do
    "Please enter a username\n>"
  end
end
