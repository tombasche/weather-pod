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
      {:grpc, "~> 0.5.0"},
      {:protobuf, "~> 0.10"}
    ]
  end
end
