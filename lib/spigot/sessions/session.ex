defmodule Spigot.Sessions.Session do
  @moduledoc """
  Session supervisor

  Starts the Foreman first
  """

  use Supervisor

  alias Spigot.Characters
  alias Spigot.Sessions.Auth
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

  def start_auth(foreman_state) do
    opts = [foreman: self()]
    {:ok, auth} = DynamicSupervisor.start_child(foreman_state.tether, {Auth, opts})
    Process.link(auth)
    foreman_state = Map.put(foreman_state, :auth, auth)
    {:ok, foreman_state}
  end

  def start_character(foreman_state, name) do
    opts = [foreman: self(), name: name]
    {:ok, character} = Characters.start(opts)
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
    opts = [foreman: self(), auth: foreman_state.auth]
    {:ok, options} = DynamicSupervisor.start_child(foreman_state.tether, {Options, opts})
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
