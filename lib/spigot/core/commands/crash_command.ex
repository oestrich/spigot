defmodule Spigot.Core.CrashCommand do
  @moduledoc """
  Crash the commands process
  """

  use Spigot, :command

  @doc """
  Raises an exception in order to crash your session
  """
  def base(_conn, _params) do
    raise "Crashing now"
  end
end
