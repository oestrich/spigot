defmodule Spigot.Conn.Private do
  @moduledoc false

  defstruct [:view]
end

defmodule Spigot.Conn do
  @moduledoc """
  Struct for tracking data being processed in a command or action
  """

  defstruct [:foreman, :character, :params, :assigns, messages: [], private: %Spigot.Conn.Private{}, lines: []]
end

defmodule Spigot.Conn.Event do
  @moduledoc """
  Send an out of band Event
  """

  defstruct [:topic, :data, type: :game]
end
