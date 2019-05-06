defmodule Engine.Conn.Private do
  @moduledoc false

  defstruct [:view]
end

defmodule Engine.Conn do
  @moduledoc """
  Struct for tracking data being processed in a command or action
  """

  defstruct [
    :foreman,
    :character,
    :params,
    :assigns,
    messages: [],
    private: %Engine.Conn.Private{},
    lines: []
  ]
end

defmodule Engine.Conn.Event do
  @moduledoc """
  Send an out of band Event
  """

  defstruct [:topic, :data, type: :game]
end
