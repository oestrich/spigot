defmodule Engine.Gossip do
  @moduledoc """
  Callback for core Gossip behaviour
  """

  @behaviour Gossip.Client.Core

  alias Engine.Players

  @impl true
  def channels(), do: Application.get_env(:spigot, :grapevine)[:channels]

  @impl true
  def players() do
    Enum.map(Players.online(), fn {_pid, character} ->
      character.name
    end)
  end

  @impl true
  def user_agent(), do: "Spigot 0.1"

  @impl true
  def authenticated(), do: :ok

  @impl true
  def message_broadcast(message) do
    params = %{
      channel: message.channel,
      name: "#{message.name}@#{message.game}",
      text: message.message
    }

    Enum.each(Players.online(), fn {pid, _} ->
      send(pid, %Spigot.Grapevine.ChatAction{action: :receive, params: params})
    end)
  end
end
