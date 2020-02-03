import Config

config :spigot, :listener, tls: true

config :logger, level: :info
config :logger, :console, format: "$time $metadata[$level] $message\n"
