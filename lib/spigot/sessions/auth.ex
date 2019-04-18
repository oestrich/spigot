defmodule Spigot.Sessions.Auth do
  @behaviour :gen_statem

  alias Spigot.Views.Login

  defstruct [:foreman]

  @impl true
  def callback_mode(), do: :state_functions

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  def start_link(opts) do
    :gen_statem.start_link(__MODULE__, opts, [])
  end

  @impl true
  def init(opts) do
    data = %__MODULE__{foreman: opts[:foreman]}
    {:ok, :prompt, data}
  end

  def prompt(:info, :welcome, data) do
    send(data.foreman, {:send, Login.render("welcome", %{})})
    :keep_state_and_data
  end

  def prompt(:info, {:recv, ""}, _data) do
    :keep_state_and_data
  end

  def prompt(:info, {:recv, _text}, data) do
    send(data.foreman, {:send, "Thanks for logging in\n"})
    send(data.foreman, {:auth, :logged_in})
    :keep_state_and_data
  end
end
