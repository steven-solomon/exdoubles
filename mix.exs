defmodule ExDoubles.MixProject do
  use Mix.Project

  def project do
    [
      app: :exdoubles,
      description: description(),
      package: package(),
      version: "0.1.2",
      elixir: "~> 1.8",
      deps: deps(),
      docs: [
        main: "ExDoubles",
        extras: ["README.md"]
      ]
    ]
  end

  def description do
    """
    ExDoubles is an opinionated mocking library for Elixir. It takes the stance that the easiest way to create loose coupling in your codebase is to follow the Dependency Inversion Principle (DIP).

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
      name: "exdoubles",
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/steven-solomon/exdoubles"
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
