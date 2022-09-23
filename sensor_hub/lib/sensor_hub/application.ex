defmodule SensorHub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: SensorHub.Supervisor]

    children = children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
    ]
  end

  def children(_target) do
    [
      {BMP280: [i2c_address: 0x77, name: BMP280]}
      {Finch, name: WeatherTrackerClient},
      {
        Publisher,
        %{
          sensors: sensors(),
          weather_tracker_url: weather_tracker_url()
        }
      }
    ]
  end

  defp sensors do
    [Sensor.new(BMP280)]
  end

  defp weather_tracker_url do
    Application.get_env(:sensor_hub, :weather_tracker_url)
  end

  def target() do
    Application.get_env(:sensor_hub, :target)
  end
end
