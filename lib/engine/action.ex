defmodule Engine.Action do
  @moduledoc """
  Action functions
  """

  def push(state, lines) do
    send(state.foreman, {:send, lines})
    state
  end

  def render(state, view, template, assigns) do
    push(state, view.render(template, assigns))
  end
end
