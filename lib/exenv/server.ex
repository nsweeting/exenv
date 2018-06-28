defmodule Exenv.Server do
  @moduledoc false

  use GenServer

  def start_link(config \\ []) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def child_spec(config) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [config]}
    }
  end

  def set_adapters(adapters) do
    GenServer.call(__MODULE__, {:set_adapters, adapters})
  end

  def load do
    GenServer.call(__MODULE__, :load)
  end

  def async_load do
    GenServer.cast(__MODULE__, :load)
  end

  def init(config) do
    config |> get_autoload_adapters() |> Exenv.load()
    {:ok, config}
  end

  def handle_call({:set_adapters, adapters}, _from, config) do
    config = Keyword.merge(config, adapters: adapters)
    {:reply, :ok, config}
  end

  def handle_call(:load, _from, config) do
    results = do_load(config)
    {:reply, results, config}
  end

  def handle_cast(:load, config) do
    do_load(config)
    {:noreply, config}
  end

  defp get_autoload_adapters(config) do
    adapters = Keyword.get(config, :adapters, [])

    Enum.filter(adapters, fn {_, opts} ->
      Keyword.get(opts, :autoload, true)
    end)
  end

  defp do_load(config) do
    adapters = Keyword.get(config, :adapters, [])
    Exenv.load(adapters)
  end
end
