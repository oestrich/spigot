defmodule Spigot.Commands.Say do
  @moduledoc """
  Local room communication
  """

  use Spigot, :command

  alias Spigot.Actions.Say

  @doc """
  Sends your message to everyone in the current room
  """
  def base(conn, %{"message" => text}) do
    conn
    |> render("text", %{text: text})
    |> render(Commands, "prompt")
    |> event(:character, Say, :broadcast, %{text: text})
  end
end
