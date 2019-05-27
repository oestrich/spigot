defmodule Spigot.Grapevine.Bottle do
  @moduledoc """
  Grapevine bottle

  Contains commands related to the Grapevine chat network
  """

  use Spigot, :bottle

  alias Spigot.Grapevine.ChatAction

  @impl true
  def actions() do
    [{ChatAction, [:broadcast, :receive]}]
  end
end
