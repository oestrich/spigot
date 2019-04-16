defmodule Spigot.Character do
  @moduledoc """
  Struct for character data
  """

  defstruct [:vitals]
end

defmodule Spigot.Character.Vitals do
  @moduledoc """
  Struct for character vitals such as health
  """

  @derive Jason.Encoder
  defstruct [
    :health_points, :max_health_points,
    :skill_points, :max_skill_points,
    :endurance_points, :max_endurance_points
  ]
end