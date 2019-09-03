defmodule Engine.Sessions.Foreman do
  @moduledoc """
  Session Foreman

  The in between process from `Engine.Telnet.Server` and the rest of
  the processes. Starts the `Engine.Sessions.Options` process on boot.
  """

  @behaviour :gen_statem

  defstruct [:session, :protocol, :tether, :auth, :character, :commands, :options]

  alias Engine.Sessions.Session

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
    data = %__MODULE__{
      session: opts[:session],
      protocol: opts[:protocol]
    }

    actions = [{:next_event, :internal, :initialize}]

    {:ok, :uninitialized, data, actions}
  end

  def uninitialized(:internal, :initialize, data) do
    {:ok, data} = Session.start_tether(data)
    {:ok, data} = Session.start_auth(data)
    {:ok, data} = Session.start_options(data)

    send(data.protocol, {:takeover, self()})

    {:next_state, :initialized, data, [{:next_event, :internal, :login}]}
  end

  def initialized(:internal, :login, data) do
    send(data.auth, :welcome)
    {:next_state, :unauthenticated, data}
  end

  def unauthenticated(:info, {:recv, :text, telnet_data}, data) do
    send(data.auth, {:recv, telnet_data})
    :keep_state_and_data
  end

  def unauthenticated(:info, {:auth, :logged_in, username}, data) do
    {:ok, data} = Session.start_character(data, username)
    {:ok, data} = Session.start_commands(data)
    send(data.commands, {:welcome, username})
    {:next_state, :authenticated, data}
  end

  def unauthenticated(type, message, data) do
    handle_common(type, message, data)
  end

  def authenticated(:info, {:recv, :text, telnet_data}, data) do
    send(data.commands, {:recv, telnet_data})
    :keep_state_and_data
  end

  def authenticated(type, message, data) do
    handle_common(type, message, data)
  end

  def handle_common(:info, {:recv, :option, option}, data) do
    send(data.options, {:recv, option})
    :keep_state_and_data
  end

  def handle_common(:info, {:send, telnet_data}, data) do
    send(data.protocol, {:send, telnet_data})
    :keep_state_and_data
  end

  def handle_common(:info, {:send, telnet_data, opts}, data) do
    opts = Enum.into(opts, %{})
    send(data.protocol, {:send, telnet_data, opts})
    :keep_state_and_data
  end

  def handle_common(:info, :stop, data) do
    send(data.protocol, :terminate)
    :keep_state_and_data
  end

  def handle_common(:info, :terminate, data) do
    Session.terminate(data)
    :keep_state_and_data
  end
end
