defmodule Spigot.Routers do
  @moduledoc """
  Parse command from a user and determine the correct command to trigger
  """

  @routers [
    Spigot.Core.Router,
    Spigot.Grapevine.Router
  ]

  @doc false
  def routers(), do: @routers

  @doc """
  Take a conn and execute a command if found
  """
  def call(conn, command_text) do
    case parse(command_text) do
      {:error, :unknown} ->
        {:error, :unknown}

      {:ok, {router, {pattern, params}}} ->
        conn = Map.put(conn, :params, params)
        router.receive(pattern, conn)
    end
  end

  @doc """
  Parse through routers to find a matching command
  """
  def parse(command_text) do
    value =
      Enum.find_value(routers(), fn router ->
        case router.parse(command_text) do
          {:ok, parse} ->
            {router, parse}

          {:error, :unknown} ->
            false
        end
      end)

    case value do
      nil ->
        {:error, :unknown}

      value ->
        {:ok, value}
    end
  end
end
