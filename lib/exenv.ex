defmodule Exenv do
  @moduledoc """
  Loads env vars using an adapter-based approach.

  Exenv dynamically assigns env vars on application start using whatever adapters
  have been configured to run. By default, Exenv is setup to use the included
  `Exenv.Adapters.Dotenv` adapter - loading env vars from a `.env` file in your
  projects directory on startup.

  ## Configuration

  If you need to further configure Exenv - it is typically done via application config.

      config :exenv, [
        adapters: [
          {Exenv.Adapters.Dotenv, [file: "path/to/.env"]}
        ]
      ]

  You can simply list the adapters and any options you would like to pass to it
  via `{MyAdapter, opts}` - where `opts` is a keyword list of options defined by
  the adapter.

  Alternatively, you can also configure Exenv to be used via your own supervision
  tree. In this case simply add the following to your config:

      config :exenv, start_on_application: false

  You can then add Exenv to your supervisor.

      children = [
        {Exenv, [adapters: [{Exenv.Adapters.Dotenv, [file: "path/to/.env"]}]]}
      ]

  """

  use Application

  @type on_load :: [{Exenv.Adapter.t(), Exenv.Adapter.result()}]

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
  @spec load() :: on_load()
  def load do
    Exenv.Server.load()
  end

  @doc """
  Loads all env vars using the adapter config provided.
  """
  @spec load(adapters :: [Exenv.Adapter.config()]) :: on_load()
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
