defmodule Spigot.Commands.Help do
  @moduledoc "View help"

  use Spigot, :command

  alias Spigot.Router

  def base(conn, _params) do
    commands =
      Enum.map(Router.commands(), fn command ->
        command
        |> to_string()
        |> String.split(".")
        |> List.last()
      end)

    conn
    |> render("base", %{commands: commands})
    |> render(Commands, "prompt")
  end

  def topic(conn, %{"topic" => topic}) do
    command =
      Router.commands()
      |> Enum.find(fn command ->
        command =
          command
          |> to_string()
          |> String.split(".")
          |> List.last()

        String.downcase(topic) == String.downcase(command)
      end)

    case is_nil(command) do
      true ->
        conn
        |> render("unknown")
        |> render(Commands, "prompt")

      false ->
        topic =
          command
          |> to_string()
          |> String.split(".")
          |> List.last()

        conn
        |> render("topic", %{topic: topic, docs: fetch_docs(command)})
        |> render(Commands, "prompt")
    end
  end

  def fetch_docs(command) do
    case Code.fetch_docs(command) do
      {:docs_v1, 2, :elixir, "text/markdown", %{"en" => docs}, _, _} ->
        docs

      _ ->
        nil
    end
  end
end
