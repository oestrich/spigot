defmodule Spigot.Grapevine do
  @moduledoc """
  OAuth helpers for Grapevine
  """

  @config Application.get_env(:spigot, :grapevine)

  def client_id(), do: @config[:client_id]

  def authorize(code) do
    params = %{
      client_id: @config[:client_id],
      client_secret: @config[:client_secret],
      code: code,
      grant_type: :authorization_code,
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
    }

    response = HTTPoison.post(@config[:host] <> "oauth/token", Jason.encode!(params), [{"Content-Type", "application/json"}])

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      _ ->
        :error
    end
  end

  def info(token) do
    headers = [
      {"Authorization", "Bearer " <> token},
      {"Accept", "application/json"}
    ]

    case HTTPoison.get(@config[:host] <> "/users/me", headers) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      _ ->
        :error
    end
  end
end
