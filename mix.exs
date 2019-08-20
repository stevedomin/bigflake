defmodule Bigflake.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bigflake,
      version: "0.5.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Bigflake.Application, []},
      env: [interface_module: Bigflake.Interface, worker_id: :default_interface]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:base62, "~> 1.2.0"},
      {:benchfella, "~> 0.3.2", only: [:dev]},
      {:credo, "~> 1.1.3", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    128-bit, k-ordered, conflict-free IDs Elixir.
    """
  end

  defp package do
    [
      maintainers: ["Steve Domin"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/stevedomin/bigflake"}
    ]
  end
end
