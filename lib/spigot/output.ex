defmodule Spigot.Output.Event do
  @moduledoc """
  Send an out of band Event
  """

  defstruct [:topic, :data]
end
