defmodule Spigot.Views.Say do
  use Spigot, :view

  def render("text", %{text: text}) do
    ~s(You say, #{IO.ANSI.green()}"#{text}"\n#{IO.ANSI.reset()})
  end
end
