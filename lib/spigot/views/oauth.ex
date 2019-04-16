defmodule Spigot.Views.OAuth do
  use Spigot, :view

  def render("authorization-request", %{params: params}) do
    %Event{
      type: :oauth,
      topic: "AuthorizationRequest",
      data: params
    }
  end
end
