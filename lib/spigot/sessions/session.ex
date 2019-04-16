defmodule Spigot.Sessions.Session do
  @moduledoc """
  Session supervisor

  Starts the Foreman first
  """

  use Supervisor

  alias Spigot.Sessions.Character
  alias Spigot.Sessions.Commands
  alias Spigot.Sessions.Foreman
  alias Spigot.Sessions.Options
  alias Spigot.Sessions.Tether

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def start_tether(foreman_state) do
    case Supervisor.start_child(foreman_state.session, {Tether, []}) do
      {:ok, tether} ->
        foreman_state = Map.put(foreman_state, :tether, tether)
        {:ok, foreman_state}

      {:error, {:already_started, tether}} ->
        foreman_state = Map.put(foreman_state, :tether, tether)
        {:ok, foreman_state}
    end
  end

  def start_character(foreman_state) do
    {:ok, character} = DynamicSupervisor.start_child(foreman_state.tether, {Character, [foreman: self()]})
    Process.link(character)
    foreman_state = Map.put(foreman_state, :character, character)
    {:ok, foreman_state}
  end

  def start_commands(foreman_state) do
    opts = [foreman: self(), character: foreman_state.character]
    {:ok, commands} = DynamicSupervisor.start_child(foreman_state.tether, {Commands, opts})
    Process.link(commands)
    foreman_state = Map.put(foreman_state, :commands, commands)
    {:ok, foreman_state}
  end

  def start_options(foreman_state) do
    {:ok, options} = DynamicSupervisor.start_child(foreman_state.tether, {Options, [foreman: self()]})
    Process.link(options)
    foreman_state = Map.put(foreman_state, :options, options)
    {:ok, foreman_state}
  end

  def terminate(foreman_state) do
    DynamicSupervisor.terminate_child(Spigot.Sessions, foreman_state.session)
  end

  def init(protocol: protocol) do
    children = [
      {Foreman, [session: self(), protocol: protocol]}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
