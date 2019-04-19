defmodule Spigot.Actions.OAuth do
  @moduledoc false

  use Spigot, :action

  require Logger

  alias Spigot.Grapevine

  def authorization_request(state, %{"host" => "grapevine.haus"}) do
    Logger.info("Starting oauth request")
    params = %{
      response_type: "code",
      client_id: Grapevine.client_id(),
      scope: "profile email",
      state: UUID.uuid4(),
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
    }

    render(state, view(), "authorization-request", %{params: params})
  end

  def authorization_request(_, _), do: :ok
end
