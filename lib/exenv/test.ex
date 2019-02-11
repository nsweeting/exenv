defmodule Exenv.Test do
  import ExUnit.Assertions, only: [assert: 1, assert: 2, refute: 1]
  import ExUnit.Callbacks, only: [start_supervised: 1]

  def refute_vars(test_vars) do
    for {key, val} <- test_vars do
      refute_var(key, val)
    end
  end

  def refute_var(key, val) do
    refute System.get_env(key) == val
  end

  def assert_vars(test_vars) do
    for {key, val} <- test_vars do
      assert_var(key, val)
    end
  end

  def assert_var(key, val) do
    assert System.get_env(key) == val
  end

  def reset_env_vars(test_vars) do
    for {key, _} <- test_vars do
      System.put_env(key, "")
    end
  end

  def setup_exenv(opts \\ []) do
    start_supervised({Exenv.Supervisor, opts})
  end
end
