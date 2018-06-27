defmodule ExenvTest do
  use ExUnit.Case

  import Exenv.Helpers

  describe "load/0" do
    test "will load env vars from the adapters" do
      setup_exenv([
        adapters: [
          {Exenv.Adapters.Mockenv.One, [env_vars: [{"FOO", "bar"}]]},
          {Exenv.Adapters.Mockenv.Two, [env_vars: [{"BAR", "baz"}]]},
        ]
      ])
      setup_mock_reciever()

      refute_receive({Exenv.Adapters.Mockenv.One, [{"FOO", "bar"}]})
      refute_receive({Exenv.Adapters.Mockenv.Two, [{"BAR", "baz"}]})

      Exenv.load()

      assert_receive({Exenv.Adapters.Mockenv.One, [{"FOO", "bar"}]})
      assert_receive({Exenv.Adapters.Mockenv.Two, [{"BAR", "baz"}]})
    end

    test "will autoload env vars if the option is specified" do
      refute_receive({Exenv.Adapters.Mockenv.One, [{"FOO", "bar"}]})
      refute_receive({Exenv.Adapters.Mockenv.Two, [{"BAR", "baz"}]})

      setup_mock_reciever()
      setup_exenv([
        adapters: [
          {Exenv.Adapters.Mockenv.One, [auto_load: true, env_vars: [{"FOO", "bar"}]]},
          {Exenv.Adapters.Mockenv.Two, [auto_load: true, env_vars: [{"BAR", "baz"}]]},
        ]
      ])

      assert_receive({Exenv.Adapters.Mockenv.One, [{"FOO", "bar"}]})
      assert_receive({Exenv.Adapters.Mockenv.Two, [{"BAR", "baz"}]})
    end

    test "will return the results of each adapter" do
      setup_exenv([
        adapters: [
          {Exenv.Adapters.Mockenv.One, []},
          {Exenv.Adapters.Mockenv.Two, []},
        ]
      ])
      result = Exenv.load()
      assert result == [{Exenv.Adapters.Mockenv.One, :ok}, {Exenv.Adapters.Mockenv.Two, :ok}]
    end
  end

  describe "async_load/0" do
    test "will async load env vars from the adapters" do
      setup_exenv([
        adapters: [
          {Exenv.Adapters.Mockenv.One, [env_vars: [{"FOO", "bar"}]]},
          {Exenv.Adapters.Mockenv.Two, [env_vars: [{"BAR", "baz"}]]},
        ]
      ])
      setup_mock_reciever()

      refute_receive({Exenv.Adapters.Mockenv.One, [{"FOO", "bar"}]})
      refute_receive({Exenv.Adapters.Mockenv.Two, [{"BAR", "baz"}]})

      assert Exenv.async_load() == :ok

      :timer.sleep(100)

      assert_receive({Exenv.Adapters.Mockenv.One, [{"FOO", "bar"}]})
      assert_receive({Exenv.Adapters.Mockenv.Two, [{"BAR", "baz"}]})
    end
  end
end
