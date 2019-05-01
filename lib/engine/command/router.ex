defmodule Engine.Command.Router do
  @moduledoc """
  Parse player input and match against known patterns
  """

  def parse(patterns, text) do
    text = String.trim(text)

    match =
      Enum.find_value(patterns, fn pattern ->
        case match_pattern(pattern, text) do
          nil ->
            false

          captures ->
            {pattern, captures}
        end
      end)

    case match != nil do
      true ->
        {:ok, match}

      false ->
        {:error, :unknown}
    end
  end

  defp match_pattern(pattern, text) do
    pattern =
      pattern
      |> String.split(" ")
      |> Enum.map(fn
        ":" <> var ->
          "(?<#{var}>.*)"

        segment ->
          segment
      end)
      |> Enum.join(" ")

    pattern = "^" <> pattern <> "$"

    pattern
    |> Regex.compile!()
    |> Regex.named_captures(text)
  end
end
