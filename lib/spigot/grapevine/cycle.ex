defmodule Spigot.Grapevine.Cycle do
  @moduledoc """
  Grapevine cycle

  Contains commands related to the Grapevine chat network
  """

  use Spigot, :cycle

  alias Spigot.Grapevine.ChatAction

  @impl true
  def actions() do
    [{ChatAction, [:broadcast, :receive]}]
  end
end
