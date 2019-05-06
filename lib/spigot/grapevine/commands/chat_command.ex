defmodule Spigot.Grapevine.ChatCommand do
  @moduledoc """
  Communicate over the Grapevine chat network
  """

  use Spigot, :command

  alias Spigot.Grapevine.ChatAction

  @doc """
  Sends your message to everyone in the current room
  """
  def base(conn, %{"channel" => channel, "message" => text}) do
    conn
    |> render("text", %{channel: channel, text: text})
    |> render(CommandsView, "prompt")
    |> event(:character, ChatAction, :broadcast, %{channel: channel, text: text})
  end
end
