defmodule SensorHub.Application do
  alias SensorHub.Sensor
  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: SensorHub.Supervisor, restart: :transient]

    children = children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    []
  end

  def children(_target) do
    [
      {BMP280, [i2c_address: 0x77, name: BMP280]},
      {
        Publisher,
        %{
          sensors: sensors(),
          channel: grpc_channel()
        }
      }
    ]
  end

  defp sensors do
    [Sensor.new(BMP280)]
  end

  def target() do
    Application.get_env(:sensor_hub, :target)
  end

  defp grpc_channel(_ = 0), do: :ignore

  defp grpc_channel(retry \\ 3) do
    env = Application.get_env(:sensor_hub, :weather_tracker_url)

    case GRPC.Stub.connect(env) do
      {:ok, channel} ->
        Logger.debug("Connected to #{env}")
        channel

      {:error, error} ->
        Logger.error(
          "[app] Couldn't connect to gRPC server due to #{error} - retrying [#{retry}]"
        )

        Process.sleep(1000)
        grpc_channel(retry - 1)
    end
  end
end
