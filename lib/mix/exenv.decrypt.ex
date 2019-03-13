defmodule Mix.Tasks.Exenv.Decrypt do
  @shortdoc "Decrypts a file using the provided master.key"
  @moduledoc """
  Decrypts a file using the provided master.key.

  The encrypted file should end in `.enc`.

      mix exenv.decrypt /config/master.key /config/secrets.env.enc

  """

  use Mix.Task

  alias Exenv.Encryption

  @impl Mix.Task
  def run([key_path, secrets_path]) do
    cwd = File.cwd!()
    full_key_path = cwd <> key_path
    encrypted_secrets_path = cwd <> secrets_path
    key = Encryption.get_master_key!(full_key_path)
    decrypted_secrets = Encryption.decrypt_secrets!(key, encrypted_secrets_path)
    decrypted_secrets_path = String.replace(encrypted_secrets_path, ".enc", "")
    File.write!(decrypted_secrets_path, decrypted_secrets)

    print_info(decrypted_secrets_path)
  end

  defp print_info(decrypted_secrets_path) do
    Mix.Shell.IO.info("""
      Secrets decrypted at #{decrypted_secrets_path}.
    """
    )
  end
end
