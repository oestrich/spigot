defmodule Spigot.Commands.Say do
  @moduledoc "Say a message"

  use Spigot, :command

  def base(conn, %{"message" => text}) do
    conn
    |> render("text", %{text: text})
    |> render(Commands, "prompt")
  end
end
