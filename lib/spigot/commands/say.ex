defmodule Spigot.Commands.Say do
  @moduledoc """
  Say a message
  """

  use Spigot, :command

  alias Spigot.Actions.Say

  @doc """
  Say text to the local room
  """
  def base(conn, %{"message" => text}) do
    conn
    |> render("text", %{text: text})
    |> render(Commands, "prompt")
    |> event(:character, Say, :broadcast, %{text: text})
  end
end
