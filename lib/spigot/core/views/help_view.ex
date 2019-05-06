defmodule Spigot.Core.HelpView do
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

  def render("topic.text", %{topic: topic, docs: docs, commands: commands}) do
    ~E"""
    <%= topic %>

    ----
    <%= render("_topic_body", %{docs: docs, commands: commands}) %>
    """
  end

  def render("topic.modal", %{topic: topic, docs: docs, commands: commands}) do
    %Event{
      topic: "Client.Modals.Open",
      data: %{
        key: "help-#{topic}",
        title: topic,
        body: render("_topic_body", %{docs: docs, commands: commands})
      }
    }
  end

  def render("_topic_body", %{docs: docs, commands: commands}) do
    ~E"""
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
