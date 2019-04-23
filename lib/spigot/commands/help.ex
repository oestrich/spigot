defmodule Spigot.Commands.Help do
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
    |> render(Commands, "prompt")
  end

  @doc """
  View a single command's help file
  """
  def topic(conn, %{"topic" => topic}) do
    with {:ok, help} <- Help.find(topic) do
      conn
      |> render("topic", help)
      |> render(Commands, "prompt")
    else
      {:error, :not_found} ->
        conn
        |> render("unknown")
        |> render(Commands, "prompt")
    end
  end
end
