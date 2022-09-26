defmodule SensorHub.Application do
  alias SensorHub.Sensor
  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: SensorHub.Supervisor]

    children = children(target(), grpc_channel())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    []
  end

  def children(_target, channel) do
    [
      {BMP280, [i2c_address: 0x77, name: BMP280]},
      {
        Publisher,
        %{
          sensors: sensors(),
          channel: channel
        }
      }
    ]
  end

  defp sensors do
    [Sensor.new(BMP280)]
  end

  defp grpc_channel do
    env = Application.get_env(:sensor_hub, :weather_tracker_url)

    case GRPC.Stub.connect(env) do
      {:ok, channel} ->
        Logger.debug("Connected to #{channel}")
        channel

      {:error, error} ->
        Logger.debug("[app] Couldn't connect to gRPC server due to #{error}")
    end
  end

  def target() do
    Application.get_env(:sensor_hub, :target)
  end
end
