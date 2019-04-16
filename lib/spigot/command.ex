defmodule Spigot.Command do
  @moduledoc """
  Functions for a command

  Push and render output
  """

  def forward(conn, process, message) do
    Map.put(conn, :messages, [{process, message} | conn.messages])
  end

  def push(conn, lines) do
    Map.put(conn, :lines, conn.lines ++ List.wrap(lines))
  end

  def render(conn, template) do
    render(conn, conn.private.view, template, %{})
  end

  def render(conn, template, assigns) when is_binary(template) and is_map(assigns) do
    render(conn, conn.private.view, template, assigns)
  end

  def render(conn, view, template) when is_atom(view) and is_binary(template) do
    render(conn, view, template, %{})
  end

  def render(conn, view, template, assigns) do
    push(conn, view.render(template, Map.merge(conn.assigns, assigns)))
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

      def call(conn, command_text) do
        case parse(command_text) do
          {:ok, {pattern, params}} ->
            conn = Map.put(conn, :params, params)
            receive(pattern, conn)

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
