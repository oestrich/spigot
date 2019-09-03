# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :spigot, :grapevine, host: "https://grapevine.haus/"

config :spigot, :listener,
  start: true,
  tls: true

config :logger, level: :info
config :logger, :console, format: "$time $metadata[$level] $message\n"

config :gossip, :callback_modules, core: Spigot.Grapevine.Gossip

if File.exists?("config/#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
