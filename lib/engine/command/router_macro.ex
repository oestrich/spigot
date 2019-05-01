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

      def call(conn, command_text) do
        case parse(command_text) do
          {:ok, {pattern, params}} ->
            conn = Map.put(conn, :params, params)
            receive(pattern, conn)

          {:error, :unknown} ->
            {:error, :unknown}
        end
      end

      @doc """
      All known commands
      """
      def commands() do
        Enum.sort(@commands)
      end

      def parse(text) do
        Engine.Command.Router.parse(@patterns, text)
      end
    end
  end

  def parse_modules({:__aliases__, _, top_module}, {:__block__, [], modules}) do
    Enum.map(modules, fn module ->
      parse_module(top_module, module)
    end)
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

      def receive(unquote(pattern), conn) do
        private = Map.put(conn.private, :view, unquote(module).view())
        conn = Map.put(conn, :private, private)
        unquote(module).unquote(fun)(conn, conn.params)
      end
    end
  end

  def parse_command(_module, _) do
    raise "Unknown function encountered"
  end
end
