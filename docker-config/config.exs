import Config

config :spigot, :grapevine, channels: []
config :spigot, :grapevine, host: "http://grapevine.local:4100/"

config :gossip, :url, "ws://grapevine.local:4110/socket"
config :gossip, :client_id, "62a8988e-f505-4e9a-ad21-e04e89f1b32b"
config :gossip, :client_secret, "3ab47e7e-010f-488a-b7d6-a474440efda5"
config :gossip, :callback_modules, core: Spigot.Grapevine.Gossip
