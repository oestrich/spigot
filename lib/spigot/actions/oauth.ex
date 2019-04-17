defmodule Spigot.Actions.OAuth do
  @moduledoc false

  use Spigot, :action

  require Logger

  def authorization_request(state, %{"host" => "grapevine.haus"}) do
    Logger.info("Starting oauth request")
    params = %{
      response_type: "code",
      client_id: "cb61f1cd-a8b8-445e-91b7-282bccbff890",
      scope: "profile email",
      state: UUID.uuid4()
    }

    render(state, view(), "authorization-request", %{params: params})
  end

  def authorization_request(_, _), do: :ok
end
