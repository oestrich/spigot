defmodule Spigot.Grapevine.Router do
  use Spigot, :router

  alias Engine.Command.Router
  alias Spigot.Grapevine.ChatCommand
  alias Spigot.Grapevine.Gossip

  @behaviour Engine.Command.Router

  @impl true
  def parse(text) do
    Engine.Command.Router.parse(routes(), text)
  end

  defp routes() do
    Enum.map(Gossip.channels(), fn channel ->
      "#{channel} :message"
    end)
  end

  @impl true
  def commands() do
    Enum.map(routes(), fn route ->
      {ChatCommand, route, :base}
    end)
  end

  @impl true
  def receive(pattern, conn) do
    channel =
      Gossip.channels()
      |> Enum.find(fn channel ->
        String.starts_with?(pattern, channel)
      end)

    params = Map.put(conn.params, "channel", channel)
    conn = Router.setup_private_conn(conn, ChatCommand)

    ChatCommand.base(conn, params)
  end
end
