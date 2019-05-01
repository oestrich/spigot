defmodule Engine.View do
  @moduledoc """
  Render output from the game
  """

  def view_module(module) do
    base_module = List.last(String.split(to_string(module), "."))
    String.to_atom(Enum.join(["Elixir", "Spigot", "Views", base_module], "."))
  end
end

defmodule Engine.View.Macro do
  @moduledoc """
  Imported into views
  """

  defmacro sigil_E({:<<>>, _, [expr]}, _opts) do
    EEx.compile_string(expr, line: __CALLER__.line + 1, trim: true)
  end
end
