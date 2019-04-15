defmodule Spigot.Conn do
  defstruct [:foreman, :params, :assigns, :lines, :events]
end

defmodule Spigot.Conn.Event do
  @moduledoc """
  Send an out of band Event
  """

  defstruct [:topic, :data]
end
