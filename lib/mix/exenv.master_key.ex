defmodule Mix.Tasks.Exenv.MasterKey do
  @shortdoc "Generates a master.key file within the given path"
  @moduledoc """
  Generates a master key file at the given path.

  The generated file will be added to your `.gitignore` file.

      mix exenv.master_key /config/master.key

  """

  use Mix.Task

  alias Exenv.Encryption

  @impl Mix.Task
  def run([]) do
    run(["/config/master.key"])
  end

  def run([path]) do
    path = sanitize_path(path)
    full_path = File.cwd!() <> path
    key = Encryption.create_master_key!(full_path)

    add_gitignore(path)
    print_info(key)
  end

  defp sanitize_path(path) do
    if String.first(path) == "/", do: path, else: "/#{path}"
  end

  defp add_gitignore(path) do
    device = File.open!(".gitignore", [:read, :append])
    gitignore = device |> IO.binread(:all) |> String.split("\n")

    unless Enum.member?(gitignore, path) do
      IO.binwrite(device, "\n")
      IO.binwrite(device, "\n")
      IO.binwrite(device, "# Ignore the master key generated for encrypted secrets.\n")
      IO.binwrite(device, path)
    end

    File.close(device)
  end

  defp print_info(path) do
    Mix.Shell.IO.info("""
      Master key generated at #{path}.
      File has been added to your projects .gitignore.
    """)
  end
end
