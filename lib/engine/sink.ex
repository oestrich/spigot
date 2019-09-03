defmodule Engine.Sink do
  @moduledoc """
  A gensever that processes actions
  """

  alias Spigot.Core.CommandsView

  defmacro use_cycles(cycles) do
    cycles
    |> Enum.map(fn cycle ->
      {:__aliases__, meta, aliases} = cycle
      Macro.expand({:__aliases__, meta, aliases ++ [:Cycle]}, __CALLER__)
    end)
    |> Enum.map(& &1.actions)
    |> List.flatten()
    |> Enum.map(fn {module, actions} ->
      quote do
        actions(unquote(module), unquote(actions))
      end
    end)
  end

  defmacro actions(module, actions) do
    Enum.map(actions, fn action ->
      quote do
        def handle_info(action = %unquote(module){action: unquote(action)}, state) do
          process_action(state, action, &(unquote(module).unquote(action) / 2))
        end
      end
    end)
  end

  def process_action(state, action, fun) do
    state = fun.(state, action.params)
    send(state.foreman, {:send, state.lines})
    maybe_send_prompt(state)
    {:noreply, Map.put(state, :lines, [])}
  end

  defp maybe_send_prompt(state) do
    text_only = Enum.filter(state.lines, &is_binary/1)

    case Enum.empty?(text_only) do
      true ->
        :ok

      false ->
        send(state.foreman, {:send, CommandsView.render("prompt", %{})})
    end
  end
end
