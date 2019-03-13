defmodule Exenv.Support.Utils do
  def setup_temp! do
    temp_path() |> File.mkdir_p!()
  end

  def teardown_temp! do
    temp_path() |> File.rm_rf!()
  end

  def temp_path do
    File.cwd!() <> "/test/temp/"
  end

  def random_key do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
  end
end
