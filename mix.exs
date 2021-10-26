defmodule Bacen.CCS.MixProject do
  use Mix.Project

  def project do
    [
      app: :bacen_ccs,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.5.8", optional: true},
      {:telemetry, "~> 0.4", optional: true},
      {:brcpfcnpj, "~> 0.2"},
      {:ex_machina, "~> 2.7", only: :test, optional: true}
    ]
  end
end
