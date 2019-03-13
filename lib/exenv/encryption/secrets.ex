defmodule Exenv.Encryption.Secrets do
  @moduledoc false

  alias Exenv.Encryption.Utils

  @aes_block_size 16
  @secrets_file_type ".enc"

  @spec encrypted_path(binary()) :: binary()
  def encrypted_path(path) do
    path <> @secrets_file_type
  end

  @spec encrypt!(binary(), binary()) :: binary() | no_return()
  def encrypt!(key, path) do
    key = Utils.decode(key)
    secrets = File.read!(path)
    encrypted_path = encrypted_path(path)
    init_vector = :crypto.strong_rand_bytes(16)
    secrets = pad(secrets, @aes_block_size)

    case :crypto.block_encrypt(:aes_cbc256, key, init_vector, secrets) do
      <<cipher_text::binary>> ->
        init_vector = Utils.encode(init_vector)
        cipher_text = Utils.encode(cipher_text)

        File.write!(encrypted_path, "#{init_vector}|#{cipher_text}")
        encrypted_path

      _x ->
        raise Exenv.Error, "encryption failed"
    end
  end

  @spec decrypt!(binary(), binary()) :: binary() | no_return()
  def decrypt!(key, path) do
    path
    |> File.read!()
    |> String.split("|")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&Utils.decode/1)
    |> case do
      [init_vector, cipher_text] ->
        key = Utils.decode(key)

        plain_text = :crypto.block_decrypt(:aes_cbc256, key, init_vector, cipher_text)
        unpad(plain_text)

      _ ->
        raise Exenv.Error, "decryption failed"
    end
  rescue
    _ -> raise Exenv.Error, "decryption failed"
  end

  defp pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> to_string(:string.chars(to_add, to_add))
  end

  defp unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end
end
