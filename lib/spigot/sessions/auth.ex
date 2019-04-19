defmodule Spigot.Sessions.Auth do
  @moduledoc """
  Authorization Process

  Handles login
  """

  use GenServer

  alias Spigot.Actions.OAuth
  alias Spigot.Grapevine
  alias Spigot.Views.Login

  defstruct [:foreman]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    data = %__MODULE__{foreman: opts[:foreman]}
    {:ok, data}
  end

  @impl true
  def handle_info(:welcome, state) do
    send(state.foreman, {:send, Login.render("welcome", %{})})
    {:noreply, state}
  end

  def handle_info({:recv, ""}, state) do
    {:noreply, state}
  end

  def handle_info({:recv, text}, state) do
    send(state.foreman, {:send, "Thanks for logging in\n"})
    send(state.foreman, {:auth, :logged_in, String.trim(text)})
    {:noreply, state}
  end

  def handle_info(%OAuth{action: :authorization_grant, params: params}, state) do
    with {:ok, token} <- Grapevine.authorize(params["code"]),
         {:ok, info} <- Grapevine.info(token["access_token"]) do
      send(state.foreman, {:auth, :logged_in, info["username"]})
    end

    {:noreply, state}
  end
end
