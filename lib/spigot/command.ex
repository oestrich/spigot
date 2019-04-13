defmodule Spigot.Command do
  @moduledoc """
  Behaviour for commands
  """

  @callback command() :: String.t()

  @callback call(map(), list()) :: {:noreply, map()}

  defmacro __using__(_opts) do
    quote do
      @view Spigot.Command.view_module(__MODULE__)

      @behaviour Spigot.Command

      import Spigot.Command.Functions

      def render(template, assigns) do
        render(@view, template, assigns)
      end
    end
  end

  def view_module(module) do
    base_module = List.last(String.split(to_string(module), "."))
    String.to_atom(Enum.join(["Elixir", "Spigot", "Sessions", "Views", base_module], "."))
  end
end

defmodule Spigot.Command.Functions do
  @moduledoc """
  Helper functions for a command

  Push and render output
  """

  def push(state, output) do
    send(state.foreman, {:send, output})
  end

  def render(view, template, assigns) do
    view.render(template, assigns)
  end
end
