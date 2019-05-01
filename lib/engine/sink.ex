defmodule Engine.Sink do
  @moduledoc """
  A gensever that processes actions
  """

  defmacro actions(module, actions) do
    Enum.map(actions, fn action ->
      quote do
        def handle_info(action = %unquote(module){action: unquote(action)}, state) do
          process_action(state, action, &unquote(module).unquote(action)/2)
        end
      end
    end)
  end

  def process_action(state, action, fun) do
    state = fun.(state, action.params)
    {:noreply, state}
  end
end
