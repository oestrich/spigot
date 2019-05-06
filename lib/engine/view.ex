defmodule Engine.View do
  @moduledoc """
  Render output from the game
  """

  def view_module(module) do
    String.to_atom(String.replace(to_string(module), "Command", "View"))
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
