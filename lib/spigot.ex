defmodule Spigot do
  @moduledoc """
  Documentation for Spigot.
  """

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def action() do
    quote do
      @view Spigot.View.view_module(__MODULE__)

      import Spigot.Action

      def view(), do: @view
    end
  end

  def command() do
    quote do
      @view Spigot.View.view_module(__MODULE__)

      import Spigot.Command

      # For the prompt
      alias Spigot.Views.Commands

      def view(), do: @view
    end
  end

  def view() do
    quote do
      @moduledoc false

      alias Spigot.Conn.Event
    end
  end

  def router() do
    quote do
      import Spigot.Command.Router
      import Spigot.Command.RouterMacro
    end
  end
end
