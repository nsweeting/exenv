defmodule Mix.Tasks.Exenv.Encrypt do
  @shortdoc "Encrypts a file using the provided master.key"
  @moduledoc """
  Encrypts a file using the provided master.key.

  The encrypted file will use the existing file name with the addition of `.enc`.
  The original unencrypted secrets file will be added to your `.gitignore`.

      mix exenv.decrypt /config/master.key /config/secrets.env

  """

  use Mix.Task

  alias Exenv.Encryption

  @impl Mix.Task
  def run([key_path, secrets_path]) do
    cwd = File.cwd!()
    full_key_path = cwd <> key_path
    full_secrets_path = cwd <> secrets_path
    key = Encryption.get_master_key!(full_key_path)
    encrypted_path = Encryption.encrypt_secrets!(key, full_secrets_path)

    add_gitignore(secrets_path)
    print_info(encrypted_path)
  end

  defp add_gitignore(path) do
    device = File.open!(".gitignore", [:read, :append])
    gitignore = device |> IO.binread(:all) |> String.split("\n")

    unless Enum.member?(gitignore, path) do
      IO.binwrite(device, "\n")
      IO.binwrite(device, "\n")
      IO.binwrite(device, "# Ignore the unencrypted secrets file.\n")
      IO.binwrite(device, path)
    end

    File.close(device)
  end

  defp print_info(encrypted_path) do
    Mix.Shell.IO.info("""
      Secrets encrypted at #{encrypted_path}.
      Unencrypted secrets have been added to your projects .gitignore.
    """
    )
  end
end
