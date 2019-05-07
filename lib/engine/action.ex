defmodule Engine.Action do
  @moduledoc """
  Action functions
  """

  def push(state, lines) do
    Map.put(state, :lines, state.lines ++ List.wrap(lines))
  end

  def render(state, view, template, assigns) do
    push(state, view.render(template, assigns))
  end
end
