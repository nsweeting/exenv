defmodule ExenvTest do
  use ExUnit.Case

  import Exenv.Test

  @test_vars [
    {"FOO", "bar"},
    {"BAR", "baz"}
  ]

  setup do
    reset_env_vars(@test_vars)

    :ok
  end

  describe "load/0" do
    test "will load env vars from the adapters" do
      setup_exenv(
        adapters: [
          {Exenv.Support.Mockenv.One, [autoload: false, env_vars: [{"FOO", "bar"}]]},
          {Exenv.Support.Mockenv.Two, [autoload: false, env_vars: [{"BAR", "baz"}]]}
        ]
      )

      refute_vars(@test_vars)

      Exenv.load()

      assert_vars(@test_vars)
    end

    test "will autoload env vars if the option is specified" do
      refute_vars(@test_vars)

      setup_exenv(
        adapters: [
          {Exenv.Support.Mockenv.One, [autoload: true, env_vars: [{"FOO", "bar"}]]},
          {Exenv.Support.Mockenv.Two, [autoload: true, env_vars: [{"BAR", "baz"}]]}
        ]
      )

      assert_vars(@test_vars)
    end

    test "will return the results of each adapter" do
      setup_exenv(
        adapters: [
          {Exenv.Support.Mockenv.One, []},
          {Exenv.Support.Mockenv.Two, []}
        ]
      )

      result = Exenv.load()
      assert result == [{Exenv.Support.Mockenv.One, :ok}, {Exenv.Support.Mockenv.Two, :ok}]
    end
  end
end
