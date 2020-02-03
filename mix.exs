defmodule Spigot.MixProject do
  use Mix.Project

  def project do
    [
      app: :spigot,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Spigot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:elixir_uuid, "~> 1.2"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:httpoison, "~> 1.5"},
      {:gossip, "~> 1.3"},
      {:jason, "~> 1.1"},
      {:ranch, "~> 1.7"},
      {:telemetry, "~> 0.4"},
      {:telnet, git: "https://github.com/oestrich/telnet-elixir.git"}
    ]
  end

  defp releases() do
    [
      spigot: [
        include_executables_for: [:unix],
        applications: [
          runtime_tools: :permanent
        ],
        config_providers: [{Spigot.ConfigProvider, "/etc/spigot/config.exs"}]
      ]
    ]
  end
end
