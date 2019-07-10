defmodule Exenv.Encryption.MasterKey do
  @moduledoc false

  alias Exenv.Utils

  @spec create!(binary() | mfa()) :: binary()
  def create!(path_or_mfa) do
    path = Utils.build_path(path_or_mfa)
    ensure_empty(path)
    generate_key(path)

    path
  end

  @spec get!(any()) :: binary() | no_return()
  def get!(path_or_mfa \\ nil)

  def get!(nil) do
    case System.get_env("MASTER_KEY") do
      <<key::binary-size(43)>> -> key
      _ -> raise Exenv.Error, "MASTER_KEY env variable missing"
    end
  end

  def get!(path) do
    path
    |> Utils.build_path()
    |> File.read!()
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
