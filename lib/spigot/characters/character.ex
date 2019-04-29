defmodule Spigot.Characters.Character do
  @moduledoc """
  Session Character

  A simple process to manage character actions
  """

  use Spigot, :sink

  alias Spigot.Actions.Combat
  alias Spigot.Character

  @timeout 15_000

  actions(Combat, [:vitals, :start, :stop, :tick])

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: pid(opts))
  end

  @doc false
  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]},
      restart: :temporary,
      shutdown: 5000,
      type: :worker
    }
  end

  @doc """
  Create a :via tuple to access the user
  """
  def pid(opts) do
    {:via, Registry, {Spigot.Characters.Registry, opts[:name]}}
  end

  def takeover(pid, opts) do
    GenServer.cast(pid, {:takeover, opts})
  end

  def init(opts) do
    state = %{
      foreman: opts[:foreman],
      combat: false,
      character: %Character{
        name: opts[:name],
      },
      vitals: %Character.Vitals{
        health_points: 40,
        max_health_points: 55,
        skill_points: 35,
        max_skill_points: 55,
        endurance_points: 45,
        max_endurance_points: 55,
      }
    }

    Process.flag(:trap_exit, true)

    {:ok, state}
  end

  def handle_cast({:takeover, opts}, state) do
    send(state.foreman, :stop)
    state = Map.put(state, :foreman, opts[:foreman])
    {:noreply, state}
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    case state.foreman == pid do
      true ->
        Process.send_after(self(), :check_foreman, @timeout)
        {:noreply, state}

      false ->
        {:noreply, state}
    end
  end

  def handle_info(:check_foreman, state) do
    case :erlang.process_info(state.foreman) do
      :undefined ->
        {:stop, :normal, state}

      _info ->
        {:noreply, state}
    end
  end
end