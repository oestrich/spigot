defmodule Spigot.Core.Router do
  use Spigot, :router

  scope(Spigot.Core) do
    module(CombatCommand) do
      command("combat start", :start)
      command("combat stop", :stop)
      command("combat tick", :tick)
    end

    module(CrashCommand) do
      command("crash", :base)
    end

    module(HelpCommand) do
      command("help", :base)
      command("help :topic", :topic)
    end

    module(LookCommand) do
      command("look", :base)
    end

    module(MovementCommand) do
      command("north", :north)
      command("south", :south)
      command("east", :east)
      command("west", :west)
    end

    module(QuitCommand) do
      command("quit", :base)
    end

    module(SayCommand) do
      command("say :message", :base)
    end

    module(VitalsCommand) do
      command("vitals", :base)
    end

    module(WhoCommand) do
      command("who", :base)
    end
  end
end
