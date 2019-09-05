defmodule Spigot.Core.HelpCommand do
  @moduledoc """
  View help
  """

  use Spigot, :command

  alias Spigot.Help

  @doc """
  List all topics available
  """
  def base(conn, _params) do
    conn
    |> render("base", %{topics: Help.topics()})
    |> render(CommandsView, "prompt")
  end

  @doc """
  View a single command's help file
  """
  def topic(conn, %{"topic" => topic}) do
    case Help.find(topic) do
      {:ok, help} ->
        conn
        |> render("topic.text", help)
        |> render("topic.modal", help)
        |> render(CommandsView, "prompt")

      {:error, :not_found} ->
        conn
        |> render("unknown")
        |> render(CommandsView, "prompt")
    end
  end
end
