defmodule Spigot.Core.SayAction do
  @moduledoc """
  Say

  Send communications to other players in the game
  """

  use Spigot, :action

  alias Engine.Players
  alias Spigot.Core.SayView

  def broadcast(state, %{text: text}) do
    Enum.each(Players.online(), fn {pid, _} ->
      send(pid, %__MODULE__{action: :receive, params: %{name: state.character.name, text: text}})
    end)

    state
  end

  def receive(state = %{character: %{name: name}}, %{name: name}) do
    state
  end

  def receive(state, %{name: name, text: text}) do
    render(state, SayView, "text", %{name: name, text: text})
  end
end
