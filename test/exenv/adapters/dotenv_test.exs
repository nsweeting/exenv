defmodule Exenv.Adapters.DotenvTest do
  use ExUnit.Case

  import Exenv.Helpers

  alias Exenv.Adapters.Dotenv

  @test_dotenv File.cwd!() <> "/test/fixtures/dotenv.env"
  @test_vars [
    {"GOOD_KEY1", "foo"},
    {"GOOD_KEY2", "bar"}
  ]

  setup do
    setup_exenv([adapters: [{Exenv.Adapters.Dotenv, []}]])
    reset_env_vars(@test_vars)

    :ok
  end

  describe "load/1" do
    test "will set env vars from a specified dotenv file" do
      refute_vars(@test_vars)

      Dotenv.load(file: @test_dotenv)

      assert_vars(@test_vars)
    end

    test "will ignore bad lines in a dotenv file" do
      Dotenv.load(file: @test_dotenv)

      assert_var("BAD_VAR", nil)
      assert_var("baz", nil)
    end

    test "will return an error tuple when the file doesnt exist" do
      assert Dotenv.load(file: "bad_file.env") == {:error, :enoent}
    end

    test "will return an error tuple when the file is a directory" do
      assert Dotenv.load(file: "test") == {:error, :eisdir}
    end
  end
end
