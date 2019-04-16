defmodule Spigot.Commands.Vitals do
  @moduledoc "Terminate your session"

  use Spigot, :command

  alias Spigot.Actions.Combat

  def base(conn, _params) do
    conn
    |> push("Sending vitals...\n")
    |> render(Commands, "prompt")
    |> event(:character, Combat, :vitals)
  end
end
