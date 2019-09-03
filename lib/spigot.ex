defmodule Spigot do
  @moduledoc """
  Documentation for Spigot.
  """

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__(opts) do
    which = opts[:type]
    apply(__MODULE__, which, [opts])
  end

  def action() do
    quote do
      @view Engine.View.view_module(__MODULE__)

      import Engine.Action

      defstruct [:action, :params]

      def view(), do: @view
    end
  end

  def command() do
    quote do
      @view Engine.View.view_module(__MODULE__)

      import Engine.Command

      # For the prompt
      alias Spigot.Core.CommandsView

      def view(), do: @view
    end
  end

  def cycle() do
    quote do
      @behaviour Engine.Cycle
    end
  end

  def router() do
    quote do
      import Engine.Command.Router
      import Engine.Command.RouterMacro
    end
  end

  def sink() do
    quote do
      use GenServer

      import Engine.Sink
    end
  end

  def view() do
    quote do
      import Engine.View.Macro

      alias Engine.Conn.Event
    end
  end
end
