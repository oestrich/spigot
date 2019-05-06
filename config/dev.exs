use Mix.Config

config :spigot, :grapevine,
  host: "http://localhost:4100/",
  channels: ["gossip", "testing"]

config :gossip, :url, "ws://localhost:4100/socket"

if File.exists?("config/dev.local.exs") do
  import_config "dev.local.exs"
end
