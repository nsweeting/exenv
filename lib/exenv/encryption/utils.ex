defmodule Exenv.Encryption.Utils do
  @moduledoc false

  @spec encode(binary()) :: binary()
  def encode(data) do
    Base.url_encode64(data, padding: false)
  end

  @spec decode(binary()) :: binary()
  def decode(data) do
    Base.url_decode64!(data, padding: false)
  end
end
