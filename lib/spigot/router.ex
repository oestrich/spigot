defmodule Spigot.Router do
  use Spigot, :router

  scope(Spigot.Sessions.Commands) do
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
      command("vitals :count", :count)
    end
  end
end
