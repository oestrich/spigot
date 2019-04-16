defmodule Spigot.Views.Login do
  use Spigot, :view

  def render("welcome", _assigns) do
    "Welcome to #{IO.ANSI.cyan()}Spigot.#{IO.ANSI.reset()}\n"
  end
end
