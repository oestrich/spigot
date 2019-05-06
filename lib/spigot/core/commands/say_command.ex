defmodule Spigot.Core.SayCommand do
  @moduledoc """
  Local room communication
  """

  use Spigot, :command

  alias Spigot.Core.SayAction

  @doc """
  Sends your message to everyone in the current room
  """
  def base(conn, %{"message" => text}) do
    conn
    |> render("text", %{text: text})
    |> render(CommandsView, "prompt")
    |> event(:character, SayAction, :broadcast, %{text: text})
  end
end
