defmodule Spigot.View do
  @moduledoc """
  Render output from the game
  """

  def view_module(module) do
    base_module = List.last(String.split(to_string(module), "."))
    String.to_atom(Enum.join(["Elixir", "Spigot", "Views", base_module], "."))
  end
end
