defmodule SensorHub.Sensor do
  defstruct [:name, :fields, :read, :convert]

  def new(name) do
    %__MODULE__{
      read: read_fn(name),
      convert: convert_fn(name),
      fields: fields(name),
      name: name
    }
  end

  @enviro_fields [
    :altitude_m,
    :pressure_pa,
    :temperature_c,
    :dew_point_c,
    :humidity_rh,
    :gas_resistance_ohms
  ]

  def fields(BMP280),
    do: @enviro_fields

  def read_fn(BMP280), do: fn -> BMP280.measure(BMP280) end

  def convert_fn(BMP280) do
    fn reading ->
      case reading do
        {:ok, measurement} ->
          Map.take(measurement, @enviro_fields)

        _ ->
          %{}
      end
    end
  end

  def measure(sensor) do
    sensor.read.()
    |> sensor.convert.()
  end
end
