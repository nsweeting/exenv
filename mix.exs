defmodule Exenv.MixProject do
  use Mix.Project

  @version "0.4.1"

  def project do
    [
      app: :exenv,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Exenv",
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Exenv, []}
    ]
  end

  defp description do
    """
    Exenv makes loading environment variables from external sources easy.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Nicholas Sweeting"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/nsweeting/exenv"}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_url: "https://github.com/nsweeting/exenv"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5.0", only: [:dev], runtime: false}
    ]
  end
end
