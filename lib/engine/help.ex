defmodule Engine.Help do
  @moduledoc """
  Generate help from commands
  """

  alias Spigot.Core.Router

  defstruct [:topic, :docs, :commands]

  @doc """
  List all topics available
  """
  def topics() do
    Router.commands()
    |> Enum.map(fn {command, _path, _fun} ->
      command
      |> to_string()
      |> String.split(".")
      |> List.last()
    end)
    |> Enum.uniq()
  end

  @doc """
  View a single command's help file
  """
  def find(topic) do
    commands =
      Enum.filter(Router.commands(), fn {command, _path, _fun} ->
        command =
          command
          |> to_string()
          |> String.split(".")
          |> List.last()

        String.downcase(topic) == String.downcase(command)
      end)

    case Enum.empty?(commands) do
      true ->
        {:error, :not_found}

      false ->
        help = %__MODULE__{
          topic: String.capitalize(topic),
          docs: fetch_module_doc(commands),
          commands: fetch_docs(commands)
        }

        {:ok, help}
    end
  end

  def fetch_module_doc([{command, _path, _fun} | _]) do
    case Code.fetch_docs(command) do
      {:docs_v1, 2, :elixir, "text/markdown", %{"en" => docs}, _, _} ->
        docs

      _ ->
        nil
    end
  end

  def fetch_docs(commands) do
    Enum.map(commands, &fetch_doc/1)
  end

  def fetch_doc({command, path, function}) do
    case Code.fetch_docs(command) do     
      {:docs_v1, 2, :elixir, "text/markdown", _, _, functions} ->
        {path, fetch_function_doc(function, functions)}

      _ ->
        nil
    end
  end

  def fetch_function_doc(function, functions) do
    Enum.find_value(functions, &find_function_doc(function, &1))
  end

  def find_function_doc(function, {{:function, function, 2}, _, _, %{"en" => docs}, _}) do
    docs
  end

  def find_function_doc(_, _), do: nil
end
