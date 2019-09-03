defmodule Engine.Characters do
  @moduledoc """
  Supervisor of sessions
  """

  alias Engine.Players

  defmacro __using__(opts) do
    character = Keyword.get(opts, :character)

    quote do
      use DynamicSupervisor

      @doc false
      def start_link(opts) do
        Engine.Characters.start_link(opts)
      end

      @doc false
      def start(opts) do
        Engine.Characters.start(unquote(character), opts)
      end

      @impl true
      def init(opts) do
        Engine.Characters.init(opts)
      end
    end
  end

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  @doc """
  Start a new Character GenServer
  """
  def start(character, opts) do
    case Players.whereis(opts[:name]) do
      nil ->
        DynamicSupervisor.start_child(__MODULE__, {character, opts})

      pid ->
        character.takeover(pid, opts)
        {:ok, pid}
    end
  end

  @doc false
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
