defmodule Exenv.Adapters.DotenvTest do
  use ExUnit.Case

  import Exenv.Test

  alias Exenv.Adapters.Dotenv

  @test_dotenv File.cwd!() <> "/test/fixtures/dotenv.env"
  @test_enc_dotenv File.cwd!() <> "/test/fixtures/dotenv.env.enc"
  @test_master_key File.cwd!() <> "/test/fixtures/master.key"
  @test_vars [
    {"GOOD_KEY1", "foo"},
    {"GOOD_KEY2", "bar"},
    {"GOOD_KEY3", "baz="}
  ]

  setup do
    setup_exenv(adapters: [{Exenv.Adapters.Dotenv, []}])
    reset_env_vars(@test_vars)

    :ok
  end

  describe "load/1" do
    test "will set env vars from a specified dotenv file" do
      refute_vars(@test_vars)

      Dotenv.load(file: @test_dotenv)

      assert_vars(@test_vars)
    end

    test "will set env vars from an mfa" do
      refute_vars(@test_vars)

      Dotenv.load(file: {__MODULE__, :test_dotenv, []})

      assert_vars(@test_vars)
    end

    test "will ignore bad lines in a dotenv file" do
      Dotenv.load(file: @test_dotenv)

      assert_var("BAD_VAR", nil)
      assert_var("baz", nil)
    end

    test "will return an error tuple when the file doesnt exist" do
      assert {:error, %File.Error{}} = Dotenv.load(file: "bad_file.env")
    end

    test "will return an error tuple when the file is a directory" do
      assert {:error, %File.Error{}} = Dotenv.load(file: "test")
    end

    test "will set env vars from a specified encrypted dotenv file using a master key file" do
      refute_vars(@test_vars)

      Dotenv.load(file: @test_enc_dotenv, encryption: [master_key: @test_master_key])

      assert_vars(@test_vars)
    end

    test "will set env vars from an mfa file using a master key mfa" do
      refute_vars(@test_vars)

      Dotenv.load(
        file: {__MODULE__, :test_enc_dotenv, []},
        encryption: [master_key: {__MODULE__, :test_master_key, []}]
      )

      assert_vars(@test_vars)
    end

    test "will set env vars from a specified encrypted dotenv file using a MASTER_KEY env var" do
      refute_vars(@test_vars)
      master_key = File.read!(@test_master_key)
      System.put_env("MASTER_KEY", master_key)

      Dotenv.load(file: @test_enc_dotenv, encryption: true)

      assert_vars(@test_vars)
    end
  end

  def test_dotenv do
    @test_dotenv
  end

  def test_enc_dotenv do
    @test_enc_dotenv
  end

  def test_master_key do
    @test_master_key
  end
end
