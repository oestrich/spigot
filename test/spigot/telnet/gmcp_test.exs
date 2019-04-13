defmodule Spigot.Telnet.GMCPTest do
  use ExUnit.Case

  alias Spigot.Telnet.GMCP

  doctest GMCP

  describe "parsing messages" do
    test "splits out the module from the data" do
      {:ok, module, data} = GMCP.parse("Client.Map {\"version\":\"1\",\"url\":\"http://example.com/map.xml\"}")

      assert module == "Client.Map"
      assert data == %{"version" => "1", "url" => "http://example.com/map.xml"}
    end

    test "handles bad json" do
      :error = GMCP.parse("Client.Map {\"version\":\"")
    end
  end
end
