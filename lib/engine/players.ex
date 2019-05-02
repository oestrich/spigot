defmodule Engine.Players do
  @moduledoc """
  Registry for keeping track of online players
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def online() do
    :ets.match(__MODULE__, {:_, :_, :"$1"})
  end

  def whereis(name) do
    case :ets.match(__MODULE__, {name, :"$1", :_}) do
      [[pid]] ->
        pid

      _ ->
        nil
    end
  end

  def online(character) do
    GenServer.cast(__MODULE__, {:online, self(), character})
  end

  def init(_) do
    {:ok, %{}, {:continue, :init}}
  end

  def handle_continue(:init, state) do
    :ets.new(__MODULE__, [:set, :protected, :named_table])
    Process.flag(:trap_exit, true)
    {:noreply, state}
  end

  def handle_cast({:online, pid, character}, state) do
    :ets.insert(__MODULE__, {character.name, pid, character})
    Process.link(pid)
    {:noreply, state}
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    case :ets.match(__MODULE__, {:"$1", pid, :_}) do
      [[key]] ->
        :ets.delete(__MODULE__, key)

      _ ->
        :ok
    end

    {:noreply, state}
  end
end
