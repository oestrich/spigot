defmodule Spigot.Views.Vitals do
  use Spigot, :view

  def render("vitals", %{vitals: vitals}) do
    %Event{
      topic: "Character.Vitals",
      data: vitals
    }
  end
end
