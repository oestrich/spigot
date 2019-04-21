defmodule Spigot.MixProject do
  use Mix.Project

  def project do
    [
      app: :spigot,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:distillery, "~> 2.0"},
      {:elixir_uuid, "~> 1.2"},
      {:httpoison, "~> 1.5"},
      {:jason, "~> 1.1"},
      {:ranch, "~> 1.7"},
      {:telnet, git: "https://github.com/oestrich/telnet-elixir.git"}
    ]
  end
end
