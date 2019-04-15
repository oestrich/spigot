defmodule Spigot.Conn.Private do
  defstruct [:view]
end

defmodule Spigot.Conn do
  defstruct [:foreman, :character, :params, :assigns, private: %Spigot.Conn.Private{}, lines: []]
end

defmodule Spigot.Conn.Event do
  @moduledoc """
  Send an out of band Event
  """

  defstruct [:topic, :data]
end
