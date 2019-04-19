use Mix.Config

config :spigot, :grapevine, host: "http://localhost:4100/"

if File.exists?("config/dev.local.exs") do
  import_config "dev.local.exs"
end
