defmodule Spigot.Views.Help do
  use Spigot, :view

  def render("base", %{commands: commands}) do
    commands =
      Enum.map(commands, fn command ->
        " - #{command}\n"
      end)

    """
    Commands available:

    #{commands}
    """
  end

  def render("topic", %{topic: topic, docs: docs}) do
    """
    #{topic}
    ----
    #{docs}
    """
  end
end
