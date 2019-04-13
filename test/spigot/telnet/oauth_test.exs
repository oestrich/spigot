defmodule Spigot.Telnet.OAuthTest do
  use ExUnit.Case

  alias Spigot.Telnet.OAuth

  doctest OAuth

  describe "parsing messages" do
    test "splits out the module from the data" do
      {:ok, module, data} = OAuth.parse("Start {\"host\":\"grapevine.haus\"}")

      assert module == "Start"
      assert data == %{"host" => "grapevine.haus"}
    end

    test "handles bad json" do
      :error = OAuth.parse("Start {\"version\":\"")
    end
  end
end
