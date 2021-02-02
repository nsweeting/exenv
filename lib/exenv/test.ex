defmodule Exenv.Test do
  import ExUnit.Assertions
  import ExUnit.Callbacks, only: [start_supervised: 1]

  @dialyzer {:nowarn_function, refute_var: 2}

  @doc """
  Refutes that a list of env vars exist.

  ## Examples
      refute_vars [{"KEY", "val"}]

  """
  @spec refute_vars(any()) :: [any()]
  def refute_vars(test_vars) do
    for {key, val} <- test_vars do
      refute_var(key, val)
    end
  end

  @doc """
  Refutes that a single env var exists.

  ## Examples
      refute_var "KEY", "val"

  """
  def refute_var(key, val) when is_binary(key) do
    refute System.get_env(key) == val
  end

  @doc """
  Asserts that a list of env vars exist.

  ## Examples
      assert_vars [{"KEY", "val"}]

  """
  def assert_vars(test_vars) do
    for {key, val} <- test_vars do
      assert_var(key, val)
    end
  end

  @doc """
  Asserts that a single env var exists.

  ## Examples
      refute_var "KEY", "val"

  """
  def assert_var(key, val) do
    assert System.get_env(key) == val
  end

  @doc """
  Resets a list of env vars to empty strings.

  ## Examples
      reset_env_vars [{"KEY", "val"}]

  """
  def reset_env_vars(env_vars) do
    for {key, _} <- env_vars do
      System.put_env(key, "")
    end
  end

  @doc """
  Sets up Exenv for a test with the provided options.

  ## Examples
      setup_exenv(adapters: [{MyAdapter, opts}])

  """
  def setup_exenv(opts \\ []) do
    start_supervised({Exenv.Supervisor, opts})
  end
end
