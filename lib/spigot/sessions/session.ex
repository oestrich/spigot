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

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def start_character(foreman_state) do
    {:ok, options} = Supervisor.start_child(foreman_state.session, {Character, [foreman: self()]})
    foreman_state = Map.put(foreman_state, :character, options)
    {:ok, foreman_state}
  end

  def start_commands(foreman_state) do
    opts = [foreman: self(), character: foreman_state.character]
    {:ok, options} = Supervisor.start_child(foreman_state.session, {Commands, opts})
    foreman_state = Map.put(foreman_state, :commands, options)
    {:ok, foreman_state}
  end

  def start_options(foreman_state) do
    {:ok, options} = Supervisor.start_child(foreman_state.session, {Options, [foreman: self()]})
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
