defmodule Spigot.Action do
  def push(state, lines) do
    send(state.foreman, {:send, lines})
  end

  def render(view, template, assigns) do
    view.render(template, assigns)
  end
end