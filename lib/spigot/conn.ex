defmodule Spigot.Conn do
  defstruct [:foreman, :character, :params, :assigns, lines: []]
end

defmodule Spigot.Conn.Event do
  @moduledoc """
  Send an out of band Event
  """

  defstruct [:topic, :data]
end
