defmodule Spigot.Characters do
  @moduledoc """
  Supervisor of sessions
  """

  use DynamicSupervisor

  alias Spigot.Characters.Character
  alias Spigot.Players

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  @doc """
  Start a new Character GenServer
  """
  def start(opts) do
    case Players.whereis(opts[:name]) do
      nil ->
        DynamicSupervisor.start_child(__MODULE__, {Character, opts})

      pid ->
        Character.takeover(pid, opts)
        {:ok, pid}
    end
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
