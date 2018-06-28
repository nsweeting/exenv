defmodule Exenv.Adapters.Mockenv do
  defmacro __using__(_) do
    quote do
      use GenServer
      use Exenv.Adapter

      alias Exenv.Config

      @impl true
      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)
      end

      @impl true
      def init(opts) do
        {:ok, opts}
      end

      @impl true
      def load(_) do
        GenServer.call(__MODULE__, :load)
      end

      @impl true
      def handle_call(:load, _from, config) do
        env_vars = Keyword.get(config, :env_vars, [])
        System.put_env(env_vars)
        {:reply, :ok, config}
      end
    end
  end
end

defmodule Exenv.Adapters.Mockenv.One do
  use Exenv.Adapters.Mockenv
end

defmodule Exenv.Adapters.Mockenv.Two do
  use Exenv.Adapters.Mockenv
end
