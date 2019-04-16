defmodule Spigot.Command.Crash do
  @moduledoc "Crash the commands process"

  use Spigot, :command

  def base(_conn, _params) do
    raise "Crashing now"
  end
end