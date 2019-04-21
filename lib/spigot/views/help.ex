defmodule Spigot.Views.Help do
  use Spigot, :view

  def render("base", %{topics: topics}) do
    topics =
      Enum.map(topics, fn topic ->
        " - #{topic}\n"
      end)

    ~E"""
    Commands available:

    <%= topics %>
    """
  end

  def render("topic", %{topic: topic, docs: docs, commands: commands}) do
    ~E"""
    <%= topic %>

    ----
    <%= docs %>


    <%= Enum.map(commands, fn command -> %>
    <%= render("_command", %{command: command}) %>
    <% end) %>
    """
  end

  def render("_command", %{command: {path, docs}}) do
    ~E"""
    <%= IO.ANSI.white() %><%= path %><%= IO.ANSI.reset() %>
    <%= docs %>
    """
  end

  def render("unknown", _assigns) do
    """
    Unknown topic
    """
  end
end
