defmodule Spigot.Core.LoginView do
  use Spigot, :view

  def render("logged-in", %{username: username}) do
    "\nWelcome to \e[38;2;169;114;218mSpigot#{IO.ANSI.reset()}, #{username}.\n"
  end

  def render("welcome", _assigns) do
    "Please enter a username\n> "
  end
end
