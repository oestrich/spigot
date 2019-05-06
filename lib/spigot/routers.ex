defmodule Spigot.Routers do
  @moduledoc """
  Parse command from a user and determine the correct command to trigger
  """

  @routers [
    Spigot.Routers.CoreRouter,
    Spigot.Routers.GrapevineRouter,
  ]

  def routers(), do: @routers

  def call(conn, command_text) do
    case parse(command_text) do
      {:error, :unknown} ->
        {:error, :unknown}

      {:ok, {router, {pattern, params}}} ->
        conn = Map.put(conn, :params, params)
        router.receive(pattern, conn)
    end
  end

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
