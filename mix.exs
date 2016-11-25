defmodule FsWatch.Mixfile do
  use Mix.Project

  def project do
    [app: :fswatch,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :porcelain]]
  end

  # Type "mix help deps" for more examples and options
  defp deps do
    [{:porcelain, "~> 2.0"}]
  end
end
