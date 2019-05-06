defmodule Engine.Grapevine do
  @moduledoc """
  OAuth helpers for Grapevine
  """

  @doc false
  def client_id(), do: Application.get_env(:gossip, :client_id)

  @doc false
  def client_secret(), do: Application.get_env(:gossip, :client_secret)

  @doc false
  def host(), do: Application.get_env(:spigot, :grapevine)[:host]

  def authorize(code) do
    params = %{
      client_id: client_id(),
      client_secret: client_secret(),
      code: code,
      grant_type: :authorization_code,
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
    }

    response =
      HTTPoison.post(host() <> "oauth/token", Jason.encode!(params), [
        {"Content-Type", "application/json"}
      ])

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

    case HTTPoison.get(host() <> "/users/me", headers) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      _ ->
        :error
    end
  end
end
