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
        mock_reciever = Config.get(:mock_reciever)
        env_vars = Keyword.get(config, :env_vars, [])

        if mock_reciever do
          send(mock_reciever, {__MODULE__, env_vars})
        end

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
