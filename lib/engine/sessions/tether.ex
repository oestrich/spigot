defmodule Engine.Sessions.Tether do
  @moduledoc """
  Tether to delete all child specs underneath on crash
  """

  use DynamicSupervisor

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
