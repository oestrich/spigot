defmodule Spigot.Command do
  @moduledoc """
  Behaviour for commands
  """

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

defmodule Spigot.Command.Router do
  def parse(patterns, text) do
    text = String.trim(text)

    match =
      Enum.find_value(patterns, fn pattern ->
        case match_pattern(pattern, text) do
          nil ->
            false

          captures ->
            {pattern, captures}
        end
      end)

    case match != nil do
      true ->
        {:ok, match}

      false ->
        {:error, :unknown}
    end
  end

  defp match_pattern(pattern, text) do
    pattern =
      pattern
      |> String.split(" ")
      |> Enum.map(fn
        ":" <> var ->
          "(?<#{var}>.*)"

        segment ->
          segment
      end)
      |> Enum.join(" ")

    pattern = "^" <> pattern <> "$"

    pattern
    |> Regex.compile!()
    |> Regex.named_captures(text)
  end
end

defmodule Spigot.Command.Router.Macro do
  @doc """
  Macro to generate the receive functions

      scope(Spigot.Sessions.Commands) do
        module(Help) do
          command("help", :base)
          command("help :topic", :topic)
        end
      end
  """
  defmacro scope(module, opts) do
    quote do
      Module.register_attribute(__MODULE__, :patterns, accumulate: true)

      unquote(parse_modules(module, opts[:do]))

      def call(state, text) do
        case parse(text) do
          {:ok, {pattern, assigns}} ->
            receive(pattern, state, assigns)

          {:error, :unknown} ->
            {:error, :unknown}
        end
      end

      def parse(text) do
        Spigot.Command.Router.parse(@patterns, text)
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

      def receive(unquote(pattern), state, command) do
        unquote(module).unquote(fun)(state, command)
      end
    end
  end

  def parse_command(_module, _) do
    raise "Unknown function encountered"
  end
end
