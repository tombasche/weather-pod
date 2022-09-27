defmodule PublisherTest do
  use ExUnit.Case, async: true

  test "timestamp is added to the measurements" do
    state = %{
      interval: 10_000,
      channel: nil,
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
