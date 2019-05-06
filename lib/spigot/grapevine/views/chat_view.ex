defmodule Spigot.Grapevine.ChatView do
  use Spigot, :view

  def render("text", %{name: name, text: text}) do
    ~s(#{IO.ANSI.blue()}#{name}#{IO.ANSI.reset()} says, #{IO.ANSI.green()}"#{text}"\n#{IO.ANSI.reset()})
  end

  def render("text", %{channel: channel, text: text}) do
    ~s([#{channel}] You say, #{IO.ANSI.green()}"#{text}"\n#{IO.ANSI.reset()})
  end
end
