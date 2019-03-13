defmodule Exenv.Encryption.MasterKey do
  @moduledoc false

  alias Exenv.Encryption.Utils

  @spec create!(binary()) :: binary()
  def create!(path) do
    ensure_empty(path)
    generate_key(path)

    path
  end

  @spec get!(any()) :: binary() | no_return()
  def get!(path \\ nil)

  def get!(path) when is_binary(path) do
    File.read!(path)
  end

  def get!(_) do
    case System.get_env("MASTER_KEY") do
      <<key::binary-size(43)>> -> key
      _ -> raise Exenv.Error, "MASTER_KEY env variable missing"
    end
  end

  defp ensure_empty(path) do
    if File.exists?(path) do
      raise Exenv.Error, """
        Master key already exists.

        Please remove this file if you wish to generate a new master key.

        - #{path}
      """
    end
  end

  defp generate_key(path) do
    key = 32 |> :crypto.strong_rand_bytes() |> Utils.encode()
    File.write!(path, key)
  end
end
