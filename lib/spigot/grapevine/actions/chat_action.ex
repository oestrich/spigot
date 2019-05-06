defmodule Spigot.Grapevine.ChatAction do
  @moduledoc """
  Chat

  Send communications to other players in the game
  """

  use Spigot, :action

  alias Engine.Players
  alias Spigot.Grapevine.ChatView

  def broadcast(state, %{channel: channel, text: text}) do
    params = %{channel: channel, name: state.character.name, text: text}

    Enum.each(Players.online(), fn {pid, _} ->
      send(pid, %__MODULE__{action: :receive, params: params})
    end)

    Gossip.broadcast(channel, %{name: state.character.name, message: text})

    state
  end

  def receive(state = %{character: %{name: name}}, %{name: name}) do
    state
  end

  def receive(state, %{channel: channel, name: name, text: text}) do
    render(state, ChatView, "text", %{channel: channel, name: name, text: text})
  end
end
