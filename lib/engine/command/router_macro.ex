defmodule Engine.Command.RouterMacro do
  @moduledoc """
  Generate the functions required to parse commands from a player
  """

  @doc """
  Macro to generate the receive functions

      scope(Spigot.Commands) do
        module(Help) do
          command("help", :base)
          command("help :topic", :topic)
        end
      end
  """
  defmacro scope(module, opts) do
    quote do
      Module.register_attribute(__MODULE__, :patterns, accumulate: true)
      Module.register_attribute(__MODULE__, :commands, accumulate: true)

      unquote(parse_modules(module, opts[:do]))

      @behaviour Engine.Command.Router

      @impl true
      def commands() do
        Enum.sort(@commands)
      end

      @impl true
      def parse(text) do
        Engine.Command.Router.parse(@patterns, text)
      end

      defoverridable parse: 1, receive: 2
    end
  end

  def parse_modules({:__aliases__, _, top_module}, {:__block__, [], modules}) do
    Enum.map(modules, fn module ->
      parse_module(top_module, module)
    end)
  end

  def parse_modules({:__aliases__, _, top_module}, {:module, opts, args}) do
    parse_module(top_module, {:module, opts, args})
  end

  def parse_module(top_module, {:module, _, args}) do
    [module, args] = args
    module = {:__aliases__, elem(module, 1), top_module ++ elem(module, 2)}

    parse_commands(module, args[:do])
  end

  def parse_module(_top_module, _) do
    raise "Unknown function encountered"
  end

  def parse_commands(module, {:__block__, [], commands}) do
    Enum.map(commands, fn command ->
      parse_command(module, command)
    end)
  end

  def parse_commands(module, {:command, opts, args}) do
    parse_command(module, {:command, opts, args})
  end

  def parse_command(module, {:command, _, args}) do
    [pattern, fun] = args

    quote do
      @patterns unquote(pattern)
      @commands {unquote(module), unquote(pattern), unquote(fun)}

      @impl true
      def receive(unquote(pattern), conn) do
        conn = Engine.Command.Router.setup_private_conn(conn, unquote(module))
        unquote(module).unquote(fun)(conn, conn.params)
      end
    end
  end

  def parse_command(_module, _) do
    raise "Unknown function encountered"
  end
end
