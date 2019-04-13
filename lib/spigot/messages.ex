defmodule Spigot.Messages do
  @moduledoc """
  High level module for messages that Spigot may return
  """

  @callback call(map(), list()) :: String.t()
end

defmodule Spigot.Messages.Goodbye do
  @moduledoc false

  @behaviour Spigot.Messages

  def call(_state, _args \\ []), do: "Goodbye!\n"
end

defmodule Spigot.Messages.Prompt do
  @moduledoc false

  @behaviour Spigot.Messages

  def call(_state, _args \\ []), do: "> "
end

defmodule Spigot.Messages.Say do
  @moduledoc false

  @behaviour Spigot.Messages

  def call(_state, [text]) do
    ~s(You say, #{IO.ANSI.green()}"#{text}"\n#{IO.ANSI.reset()})
  end
end

defmodule Spigot.Messages.Unknown do
  @moduledoc false

  @behaviour Spigot.Messages

  def call(_state, _args \\ []), do: "What?\n"
end

defmodule Spigot.Messages.Welcome do
  @moduledoc false

  @behaviour Spigot.Messages

  def call(state, _args \\ []) do
    [
      "Welcome to #{IO.ANSI.cyan()}Spigot.#{IO.ANSI.reset()}\n",
      Spigot.Messages.Character.Vitals.call(state)
    ]
  end
end

defmodule Spigot.Messages.Character.Vitals do
  @moduledoc false

  @behaviour Spigot.Messages

  def call(state, _args \\ []) do
    <<255, 250, 201>> <> "Character.Vitals " <> Jason.encode!(state.vitals) <> <<255, 240>>
  end
end
