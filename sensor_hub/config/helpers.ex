defmodule ConfigHelpers do
  def env_or_throw(key) do
    value = System.get_env(key)

    if value == nil do
      Mix.raise("#{key} must be set - did you run ./firmware.sh?")
    end

    IO.puts("Retrieved #{key} from env set to '#{value}'")
    value
  end
end
