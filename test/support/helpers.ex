defmodule Exenv.Helpers do
  import ExUnit.Assertions
  import ExUnit.Callbacks

  alias Exenv.Config

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
    {:ok, pid} = Exenv.start_link(opts)
    on_exit(fn ->
      Process.exit(pid, :kill)
    end)
  end

  def setup_mock_reciever do
    Config.set(:mock_reciever, self())
  end
end
