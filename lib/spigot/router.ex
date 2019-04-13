defmodule Spigot.Router do
  use Spigot, :router

  scope(Spigot.Sessions.Commands) do
    module(Combat) do
      command("combat start", :start)
      command("combat stop", :stop)
      command("combat tick", :tick)
    end

    module(Help) do
      command("help", :base)
      command("help :topic", :topic)
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
  end
end
