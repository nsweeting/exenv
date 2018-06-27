defmodule Exenv do
  use Application

  alias Exenv.Config
  alias Exenv.Server

  def start(_type, _args) do
    if Config.get(:start_on_application) do
      start_link()
    else
      Supervisor.start_link([], strategy: :one_for_one)
    end
  end

  def start_link(opts \\ []) do
    Exenv.Supervisor.start_link(opts)
  end

  def child_spec(opts \\ []) do
    %{
      id: Exenv.Supervisor,
      start: {Exenv.Supervisor, :start_link, [opts]}
    }
  end

  @doc """
  Loads all env vars using the adapters defined within our config.
  """
  @spec load() :: Exenv.Adapter.result() | no_return
  def load do
    Server.load()
  end

  @doc """
  Loads all env vars asynchronously using the adapters defined within our config.
  """
  @spec async_load() :: :ok | no_return
  def async_load do
    Server.async_load()
  end

  @doc """
  Loads all env vars using the adapter config provided.
  """
  @spec load(adapters :: [Exenv.Adapter.config()]) :: [{Exenv.Adapter.t(), Exenv.Adapter.result()}]
  def load(adapters) when is_list(adapters) do
    for {adapter, opts} <- adapters do
      result = load(adapter, opts)
      {adapter, result}
    end
  end

  @doc """
  Loads env vars using the adapter and options provided.
  """
  @spec load(adapter :: Exenv.Adapter.t(), opts :: keyword()) :: Exenv.Adapter.result()
  def load(adapter, opts) when is_atom(adapter) do
    apply(adapter, :load, [opts])
  end
end
