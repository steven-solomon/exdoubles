defmodule Elephant.MixProject do
  use Mix.Project

  def project do
    [
      app: :elephant,
      description: description(),
      package: package(),
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "Elephant",
        extras: ["README.md"]
      ]
    ]
  end

  def description do
    """
    Elephant is an opinionated mocking library for Elixir. It takes the stance that the easiest way to create loose coupling in your codebase is to follow the Dependency Inversion Principle (DIP).

    This framework allows adhoc mocks so that you can emulate edge cases in your tests.
    """
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      name: "exunit_elephant",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/steven-solomon/elephant"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
    ]
  end
end
