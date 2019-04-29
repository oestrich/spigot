defmodule Spigot.Application do
  @moduledoc false

  use Application

  @start_listener Application.get_env(:spigot, :listener)[:start]

  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: Spigot.Characters.Registry]},
      {Spigot.Characters, [name: Spigot.Characters]},
      {Spigot.Sessions, [name: Spigot.Sessions]}
    ]

    children = maybe_add_listener(children)

    opts = [strategy: :one_for_one, name: Spigot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp maybe_add_listener(children) do
    case @start_listener do
      true ->
        [{Spigot.Listener, []} | children]

      false ->
        children
    end
  end
end
