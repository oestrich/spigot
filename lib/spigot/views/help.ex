defmodule Spigot.Views.Help do
  use Spigot, :view

  def render("base", _assigns) do
    """
    Commands available:

    - quit
    - say
    - vitals
    """
  end
end
