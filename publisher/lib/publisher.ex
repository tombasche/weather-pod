defmodule Publisher do
  use GenServer, restart: :transient
  use GRPC.Server, service: WeatherConditionService.Service

  require Logger

  def start_link(options \\ %{}) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @impl true
  def init(options) do
    state = %{
      source: options[:source],
      interval: options[:interval],
      sensors: options[:sensors],
      channel: options[:channel],
      measurements: :no_measurements
    }

    schedule_next_publish(state.interval)
    {:ok, state}
  end

  defp schedule_next_publish(interval) do
    Process.send_after(self(), :publish_data, interval)
  end

  @impl true
  def handle_info(:publish_data, state) do
    {:noreply, state |> measure() |> publish()}
  end

  def measure(state) do
    base = %{
      timestamp: DateTime.to_string(DateTime.utc_now()),
      source: state.source
    }

    measurements =
      Enum.reduce(state.sensors, base, fn sensor, acc ->
        sensor_data = sensor.read.() |> sensor.convert.()
        Map.merge(acc, sensor_data)
      end)

    %{state | measurements: measurements}
  end

  defp publish(state) do
    result = WeatherConditionEvent.new(state.measurements)

    state.channel
    |> WeatherConditionService.Stub.create(result)

    schedule_next_publish(state.interval)

    %{
      source: state.source,
      interval: state.interval,
      sensors: state.sensors,
      channel: state.channel,
      measurements: state.measurements
    }
  end
end
