defmodule Spigot.Actions.Say do
  @moduledoc """
  Say

  Send communications to other players in the game
  """

  use Spigot, :action

  alias Engine.Players
  alias Spigot.Actions
  alias Spigot.Views

  def broadcast(state, %{text: text}) do
    Enum.map(Players.online(), fn {pid, _} ->
      send(pid, %Actions.Say{action: :receive, params: %{name: state.character.name, text: text}})
    end)

    state
  end

  def receive(state = %{character: %{name: name}}, %{name: name}) do
    state
  end

  def receive(state, %{name: name, text: text}) do
    render(state, Views.Say, "text", %{name: name, text: text})
  end
end
