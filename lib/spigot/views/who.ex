defmodule Spigot.Views.Who do
  use Spigot, :view

  def render("who", _assigns) do
    "Other players online:\n"
  end
end
