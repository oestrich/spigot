defmodule Spigot.Core.CommandsView do
  use Spigot, :view

  alias Engine.Conn.Prompt

  def render("prompt", _assigns) do
    %Prompt{text: "> "}
  end

  def render("unknown", _assigns) do
    "What?\n"
  end
end
