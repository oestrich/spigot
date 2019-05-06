defmodule Spigot.Core.HelpCommand do
  @moduledoc """
  View help
  """

  use Spigot, :command

  alias Engine.Help

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
    with {:ok, help} <- Help.find(topic) do
      conn
      |> render("topic.text", help)
      |> render("topic.modal", help)
      |> render(CommandsView, "prompt")
    else
      {:error, :not_found} ->
        conn
        |> render("unknown")
        |> render(CommandsView, "prompt")
    end
  end
end
