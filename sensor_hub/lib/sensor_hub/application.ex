defmodule SensorHub.Application do
  alias SensorHub.Sensor
  require Logger

  use Application

  @grpc_wait_time_ms 1000
  @grpc_retries 3

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: SensorHub.Supervisor]

    children = children(target())

    Supervisor.start_link(children, opts)
  end

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
          channel: grpc_channel(grpc_env()),
          interval: polling_interval()
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

  def grpc_env() do
    Application.get_env(:sensor_hub, :weather_tracker_url)
  end

  defp grpc_channel(env, retry \\ @grpc_retries)

  defp grpc_channel(env, _ = 0) do
    raise RuntimeError, message: "Failed to connect to gRPC env #{env}"
  end

  defp grpc_channel(env, retry) do
    case GRPC.Stub.connect(env) do
      {:ok, channel} ->
        Logger.debug("Connected to #{env}")
        channel

      {:error, error} ->
        Logger.error(
          "[app] Couldn't connect to gRPC server due to #{error} - retrying [#{retry}]"
        )

        Process.sleep(@grpc_wait_time_ms)
        grpc_channel(env, retry - 1)
    end
  end

  defp polling_interval() do
    Application.get_env(:sensor_hub, :polling_interval)
  end
end
