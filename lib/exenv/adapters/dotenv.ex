defmodule Exenv.Adapters.Dotenv do
  @moduledoc """
  Loads env vars from `.env` files.

  Below is a simple example of a `.env` file:

      KEY1=val
      KEY2=val
      KEY3=val

  Assuming we have the above file in our project root directory, we would be
  able to access any of the above env vars.

      System.get_env("KEY1")

  By default, this adapter is set to start automatically on `Exenv` startup. It
  also has support for encrypted `.env` files.

  """

  use Exenv.Adapter

  @doc """
  Loads the system env vars from a `.env` specified in the options.

  ## Options
    * `:file` - the file path in which to read the `.env` from. By default this
    is a `.env` file in your projects root directory.
    * `:encryption` - options used to decrypt files. Please see `Exenv.read_file/2`
    for the options available.

  """
  @impl true
  def load(opts) do
    with {:ok, env_file} <- get_env_file(opts) do
      env_vars = parse_raw(env_file)
      System.put_env(env_vars)
    end
  end

  defp get_env_file(opts) do
    file = Keyword.get_lazy(opts, :file, fn -> File.cwd!() <> "/.env" end)
    Exenv.read_file(file, opts)
  end

  defp parse_raw(binary) do
    binary
    |> String.split("\n")
    |> Stream.map(&parse_line(&1))
    |> Stream.map(&parse_var(&1))
    |> Stream.filter(&(valid_var?(&1) == true))
    |> Enum.to_list()
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split("=", parts: 2)
    |> List.to_tuple()
  end

  defp parse_var({key, val}) do
    {key |> String.trim() |> String.upcase(), String.trim(val)}
  end

  defp parse_var(_var) do
    :error
  end

  defp valid_var?({key, val}) when is_binary(key) and is_binary(val) do
    true
  end

  defp valid_var?(_) do
    false
  end
end
