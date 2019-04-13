defmodule Spigot.Sessions.Views do
  @moduledoc """
  Render output from the game
  """

  defmacro __using__(_opts) do
    quote do
      @moduledoc false
    end
  end
end

defmodule Spigot.Sessions.Views.Commands do
  @moduledoc false

  use Spigot.Sessions.Views

  def render("prompt", _assigns) do
    "> "
  end

  def render("unknown", _assigns) do
    "What?\n"
  end
end

defmodule Spigot.Sessions.Views.Help do
  @moduledoc false

  use Spigot.Sessions.Views

  def render("base", _assigns) do
    """
    Commands available:

    - quit
    - say
    - vitals
    """
  end
end

defmodule Spigot.Sessions.Views.Login do
  @moduledoc false

  use Spigot.Sessions.Views

  alias Spigot.Sessions.Views.Vitals

  def render("welcome", assigns) do
    [
      "Welcome to #{IO.ANSI.cyan()}Spigot.#{IO.ANSI.reset()}\n",
      Vitals.render("vitals", assigns)
    ]
  end
end

defmodule Spigot.Sessions.Views.Say do
  @moduledoc false

  use Spigot.Sessions.Views

  def render("text", %{text: text}) do
    ~s(You say, #{IO.ANSI.green()}"#{text}"\n#{IO.ANSI.reset()})
  end
end

defmodule Spigot.Sessions.Views.Quit do
  @moduledoc false

  use Spigot.Sessions.Views

  def render("goodbye", _assigns) do
    "Goodbye!\n"
  end
end

defmodule Spigot.Sessions.Views.Vitals do
  @moduledoc false

  use Spigot.Sessions.Views

  alias Spigot.Output.Event

  def render("vitals", %{vitals: vitals}) do
    %Event{
      topic: "Character.Vitals",
      data: vitals
    }
  end
end
