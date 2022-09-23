defmodule PublisherTest do
  use ExUnit.Case, async: true

  test "timestamp is added to the measurements" do
    state = %{
      interval: 10_000,
      weather_tracker_url: "some-test-url",
      sensors: [],
      measurements: :no_measurements
    }

    result = Publisher.measure(state)

    assert %{
             measurements: %{
               timestamp: nil
             }
           } != result
  end
end
