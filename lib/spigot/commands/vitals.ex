defmodule Spigot.Commands.Vitals do
  @moduledoc "Terminate your session"

  use Spigot, :command

  def base(conn, _params) do
    conn
    |> push("Sending vitals...\n")
    |> render(Commands, "prompt")
    |> forward(:character, {:send, :vitals})
  end
end
