defmodule Spigot do
  @moduledoc """
  Documentation for Spigot.
  """

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def command() do
    quote do
      @view Spigot.Command.view_module(__MODULE__)

      import Spigot.Command.Functions

      alias Spigot.View.Commands

      def render(template, assigns) do
        render(@view, template, assigns)
      end
    end
  end

  def view() do
    quote do
      @moduledoc false
    end
  end

  def router() do
    quote do
      import Spigot.Command.Router
      import Spigot.Command.Router.Macro
    end
  end
end
