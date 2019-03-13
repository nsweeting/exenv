defmodule Exenv.Encryption do
  @moduledoc """
  Provides support for secrets encryption.

  Exenv supports file encryption out of the box. As a result, most adapters will
  also support encryption. This allows you to keep an encrypted secrets file
  checked into your repository. As long as you provide access to a master
  key via the env var `"MASTER_KEY"` or file, you will be able to transparently
  load env vars from your encrypted secrets file.

  To start using encryption, you must first generate a master key:

        mix exenv.master_key /config/master.key

  The above will generate a master key at `/config/master.key`

  You can then encrypt your secrets file:

        mix exenv.encrypt /config/master.key /config/.env

  The above will encrypt the `/config/.env` file using the key at `/config/master.key`

  You can also decrypt your secrets at any time if you wish to add to them:

      mix exenv.decrypt /config/master.key /config/.env.enc

  The above will decrypt the `/config/.env.enc` file using the key at `/config/master.key`
  and create a new file at `/config/.env` contining the decrypted secrets.

  Encryption options are passed along with adapter options. Please consult the
  options available to individual adapters for further details.

      {Exenv.Adapters.Dotenv, [file: "path/to/.env", encryption: true]}

  """

  @doc """
  Encrypts the secrets located at `path` using `key`.

  Returns the path to the new encrypted file.
  """
  @spec encrypt_secrets!(binary(), binary()) :: binary() | no_return()
  defdelegate encrypt_secrets!(key, path), to: Exenv.Encryption.Secrets, as: :encrypt!

  @doc """
  Decrypts the secrets at `path` using `key`.

  Returns the decrypted secrets.
  """
  @spec decrypt_secrets!(binary(), binary()) :: binary() | no_return()
  defdelegate decrypt_secrets!(key, path), to: Exenv.Encryption.Secrets, as: :decrypt!

  @doc """
  Attempts to get the master key.

  If provided `path` it will read the key from path. If not provided a path,
  it will get the contents of the env var `"MASTER_KEY"`.
  """
  @spec get_master_key!(any()) :: binary() | no_return()
  defdelegate get_master_key!(path \\ nil), to: Exenv.Encryption.MasterKey, as: :get!

  @doc """
  Creates a master key at `path`.

  Returns the path to the new master key file.
  """
  @spec create_master_key!(binary()) :: binary() | no_return()
  defdelegate create_master_key!(path), to: Exenv.Encryption.MasterKey, as: :create!
end
