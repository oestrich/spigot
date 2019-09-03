defmodule Spigot.Core.SayView do
  use Spigot, :view

  import IO.ANSI, only: [green: 0, reset: 0, yellow: 0]

  def render("text", %{name: name, text: text}) do
    ~E"""
    <%= yellow() %><%= name %><%= reset() %> says, <%= green() %>"<%= text %>"
    <%= reset() %>
    """
  end

  def render("text", %{text: text}) do
    ~i(You say, #{green()}"#{text}"\n#{reset()})
  end
end
