defmodule Spigot.Views.Who do
  use Spigot, :view

  def render("who", %{players: players}) do
    ~E"""
    Other players online:
    <%= Enum.map(players, fn player -> %>
      - <%= IO.ANSI.white() %><%= player.name %><%= IO.ANSI.reset() %>
    <% end) %>
    """
  end
end
