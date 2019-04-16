defmodule Spigot.View do
  @moduledoc """
  Render output from the game
  """

  def view_module(module) do
    base_module = List.last(String.split(to_string(module), "."))
    String.to_atom(Enum.join(["Elixir", "Spigot", "View", base_module], "."))
  end
end

defmodule Spigot.View.Commands do
  @moduledoc false

  use Spigot, :view

  def render("prompt", _assigns) do
    "> "
  end

  def render("unknown", _assigns) do
    "What?\n"
  end
end

defmodule Spigot.View.Combat do
  @moduledoc false

  use Spigot, :view

  def render("start", _assigns) do
    "Starting combat\n"
  end

  def render("stop", _assigns) do
    "Stopping combat\n"
  end

  def render("tick", _assigns) do
    """
    You attack the #{IO.ANSI.yellow()}enemy#{IO.ANSI.reset()}.
    The #{IO.ANSI.yellow()}enemy#{IO.ANSI.reset()} attacks you.
    """
  end
end

defmodule Spigot.View.Help do
  @moduledoc false

  use Spigot, :view

  def render("base", _assigns) do
    """
    Commands available:

    - quit
    - say
    - vitals
    """
  end
end

defmodule Spigot.View.Login do
  @moduledoc false

  use Spigot, :view

  def render("welcome", _assigns) do
    "Welcome to #{IO.ANSI.cyan()}Spigot.#{IO.ANSI.reset()}\n"
  end
end

defmodule Spigot.View.OAuth do
  @moduledoc false

  use Spigot, :view

  def render("authorization-request", %{params: params}) do
    %Event{
      type: :oauth,
      topic: "AuthorizationRequest",
      data: params
    }
  end
end

defmodule Spigot.View.Say do
  @moduledoc false

  use Spigot, :view

  def render("text", %{text: text}) do
    ~s(You say, #{IO.ANSI.green()}"#{text}"\n#{IO.ANSI.reset()})
  end
end

defmodule Spigot.View.Quit do
  @moduledoc false

  use Spigot, :view

  def render("goodbye", _assigns) do
    "Goodbye!\n"
  end
end

defmodule Spigot.View.Vitals do
  @moduledoc false

  use Spigot, :view

  def render("vitals", %{vitals: vitals}) do
    %Event{
      topic: "Character.Vitals",
      data: vitals
    }
  end
end

defmodule Spigot.View.Who do
  @moduledoc false

  use Spigot, :view

  def render("who", _assigns) do
    "Other players online:\n"
  end
end
