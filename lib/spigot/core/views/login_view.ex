defmodule Spigot.Core.LoginView do
  use Spigot, :view

  def render("logged-in", %{username: username}) do
    "\nWelcome to #{IO.ANSI.cyan()}Spigot#{IO.ANSI.reset()}, #{username}.\n"
  end

  def render("welcome", _assigns) do
    "Please enter a username\n> "
  end
end
