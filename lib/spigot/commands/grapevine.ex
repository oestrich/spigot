defmodule Spigot.Commands.Grapevine do
  @moduledoc """
  Communicate over the Grapevine chat network
  """

  use Spigot, :command

  alias Spigot.Actions.Say

  @doc """
  Sends your message to everyone in the current room
  """
  def base(conn, %{"channel" => channel, "message" => text}) do
    conn
    |> render("text", %{channel: channel, text: text})
    |> render(Commands, "prompt")
    |> event(:character, Say, :broadcast, %{channel: channel, text: text})
  end
end
