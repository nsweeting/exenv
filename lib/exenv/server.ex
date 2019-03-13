defmodule Exenv.Server do
  @moduledoc false

  use GenServer

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(config \\ []) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def child_spec(config) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [config]}
    }
  end

  @spec set_adapters(any()) :: :ok
  def set_adapters(adapters) do
    GenServer.call(__MODULE__, {:set_adapters, adapters})
  end

  @spec load() :: Exenv.on_load()
  def load do
    GenServer.call(__MODULE__, :load)
  end

  @doc false
  @impl true
  def init(config) do
    autoload_adapters(config)
    {:ok, config}
  end

  @doc false
  @impl true
  def handle_call({:set_adapters, adapters}, _from, config) do
    config = Keyword.merge(config, adapters: adapters)
    {:reply, :ok, config}
  end

  def handle_call(:load, _from, config) do
    results = do_load(config)
    {:reply, results, config}
  end

  defp autoload_adapters(config) do
    config
    |> Keyword.get(:adapters, [])
    |> Enum.filter(fn {_, opts} -> Keyword.get(opts, :autoload, true) end)
    |> Exenv.load()
  end

  defp do_load(config) do
    adapters = Keyword.get(config, :adapters, [])
    Exenv.load(adapters)
  end
end
