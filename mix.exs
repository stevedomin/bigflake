defmodule Bigflake.Mixfile do
  use Mix.Project

  def project do
    [app: :bigflake,
     version: "0.1.0",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: description,
     package: package]
  end

  def application do
    [applications: [:logger],
     mod: {Bigflake.Application, []},
     env: [interface_module: Bigflake.Interface,
           worker_id: :default_interface]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [{:ecto, "2.0.0-beta.1", optional: true},
     {:exprof, "~> 0.2.0", only: [:dev, :test]},
     {:benchfella, "~> 0.3.2", only: [:dev]},
     {:credo, "~> 0.3", only: [:dev]}]
  end

  defp description do
    """
    128-bit, k-ordered, conflict-free IDs Elixir.
    """
  end

  defp package do
    [maintainers: ["Steve Domin"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/stevedomin/bigflake"}]
  end
end
