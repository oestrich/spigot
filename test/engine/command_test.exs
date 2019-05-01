defmodule Engine.Command.RouterTest do
  use ExUnit.Case

  alias Engine.Command.Router

  describe "parsing commands" do
    test "finding the matching pattern" do
      patterns = ["quit", "help", "help :topic"]

      assert {:ok, {"help", %{}}} = Router.parse(patterns, "help ")
      assert {:ok, {"help :topic", %{"topic" => "topic"}}} = Router.parse(patterns, "help topic")
    end
  end
end
