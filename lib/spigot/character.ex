defmodule Spigot.Character do
  @moduledoc """
  Session Character

  A simple process to manage character actions
  """

  use Spigot, :sink

  alias Engine.Players
  alias Spigot.Actions.Combat
  alias Spigot.Actions.Say
  alias Spigot.Character.Vitals

  defstruct [:name]

  @timeout 15_000

  actions(Combat, [:vitals, :start, :stop, :tick])
  actions(Say, [:broadcast, :receive])

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
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

  def takeover(pid, opts) do
    GenServer.cast(pid, {:takeover, opts})
  end

  def init(opts) do
    state = %{
      foreman: opts[:foreman],
      combat: false,
      character: %__MODULE__{
        name: opts[:name],
      },
      vitals: %Vitals{
        health_points: 40,
        max_health_points: 55,
        skill_points: 35,
        max_skill_points: 55,
        endurance_points: 45,
        max_endurance_points: 55,
      }
    }

    Process.flag(:trap_exit, true)
    Players.online(state.character)

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
