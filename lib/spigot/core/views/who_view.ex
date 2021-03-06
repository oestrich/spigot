defmodule Spigot.Core.WhoView do
  use Spigot, :view

  def render("who", %{players: players}) do
    ~E"""
    Other players online:
    <%= Enum.map(players, fn player -> %>
      - <%= IO.ANSI.yellow() %><%= player.name %><%= IO.ANSI.reset() %>
    <% end) %>
    """
  end
end
