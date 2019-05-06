defmodule Spigot.Routers.CoreRouter do
  use Spigot, :router

  scope(Spigot.Commands) do
    module(Combat) do
      command("combat start", :start)
      command("combat stop", :stop)
      command("combat tick", :tick)
    end

    module(Crash) do
      command("crash", :base)
    end

    module(Help) do
      command("help", :base)
      command("help :topic", :topic)
    end

    module(Look) do
      command("look", :base)
    end

    module(Movement) do
      command("north", :north)
      command("south", :south)
      command("east", :east)
      command("west", :west)
    end

    module(Quit) do
      command("quit", :base)
    end

    module(Say) do
      command("say :message", :base)
    end

    module(Vitals) do
      command("vitals", :base)
    end

    module(Who) do
      command("who", :base)
    end
  end
end
