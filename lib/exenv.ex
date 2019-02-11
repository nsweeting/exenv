defmodule Exenv do
  use Application

  @impl true
  @spec start(any(), any()) :: {:ok, pid()}
  def start(_type, _args) do
    if Exenv.Config.get(:start_on_application) do
      start_link()
    else
      Supervisor.start_link([], strategy: :one_for_one)
    end
  end

  @doc """
  Starts the Exenv process.
  """
  @spec start_link(any()) :: Supervisor.on_start()
  def start_link(opts \\ []) do
    Exenv.Supervisor.start_link(opts)
  end

  @doc false
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
    Exenv.Server.load()
  end

  @doc """
  Loads all env vars using the adapter config provided.
  """
  @spec load(adapters :: [Exenv.Adapter.config()]) :: [
          {Exenv.Adapter.t(), Exenv.Adapter.result()}
        ]
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
  def load(adapter, opts) when is_atom(adapter) and is_list(opts) do
    apply(adapter, :load, [opts])
  end
end
