defmodule Engine.Sessions do
  @moduledoc """
  Supervisor of sessions
  """

  use DynamicSupervisor

  alias Engine.Sessions.Foreman
  alias Engine.Sessions.Session

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  def start(protocol) do
    {:ok, session} = DynamicSupervisor.start_child(__MODULE__, {Session, [protocol: protocol]})

    foreman =
      session
      |> Supervisor.which_children()
      |> Enum.find_value(fn
        {Foreman, pid, _, _} ->
          pid

        _ ->
          false
      end)

    {:ok, foreman}
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
