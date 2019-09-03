defmodule Engine.Cycle do
  @moduledoc """
  A cycle is a grouping of commands, actions, views, and a router.
  """

  @typedoc """
  An Action module along with the functions that should be handled
  """
  @type action() :: {atom(), [atom()]}

  @doc """
  Get all actions that the cycle contains
  """
  @callback actions() :: [action()]
end
