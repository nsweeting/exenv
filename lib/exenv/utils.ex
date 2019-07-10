defmodule Exenv.Utils do
  @moduledoc false

  @spec build_path(binary() | mfa()) :: binary()
  def build_path(path) when is_binary(path) do
    path
  end

  def build_path({mod, fun, args}) do
    apply(mod, fun, args)
  end

  @spec encode(binary()) :: binary()
  def encode(data) do
    Base.url_encode64(data, padding: false)
  end

  @spec decode(binary()) :: binary()
  def decode(data) do
    Base.url_decode64!(data, padding: false)
  end
end
