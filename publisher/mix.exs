defmodule Publisher.MixProject do
  use Mix.Project

  def project do
    [
      app: :publisher,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:finch, "~> 0.13"},
      {:jason, "~> 1.4"}
    ]
  end
end
