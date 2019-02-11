defmodule Exenv.Adapter do
  @moduledoc """
  Defines an Exenv adapter.

  An Exenv adapter is simply a module that adheres to the callbacks required. It
  can be as simple as:

      defmodule MyAdapter do
        use Exenv.Adapter

        @imple true
        def load(opts) do
          # load some system env vars

          :ok
        end
      end

  Some adapters may be simple and do not require a process on their own. But if
  some form of state is needed, we can also make our adapter process-based.
  If we define our adapter within the normal Exenv startup flow, this process
  will then be automatically started and supervised. Below is an example:

      defmodule MyAdapter do
        use Exenv.Adapter
        use GenServer

        @impl true
        def start_link(opts) do
          GenServer.start_link(__MODULE__, opts, name: __MODULE__)
        end

        @impl true
        def init(opts) do
          {:ok, opts}
        end

        @impl true
        def load(opts) do
          # load some system env vars

          GenServer.call(__MODULE__, {:load, opts})
        end

        @impl true
        def handle_call({:load, opts}, _from, config) do
          # load some system env vars

          {:reply, :ok, config}
        end
      end

  And thats it! We can know start using our new adapter.
  """

  @doc """
  Starts the adapter process if required.
  """
  @callback start_link(opts :: keyword()) :: GenServer.on_start()

  @doc """
  Loads the system env vars using the adapter and options provided.
  """
  @callback load(opts :: keyword()) :: result()

  @type t :: module()

  @type config :: {Exenv.Adapter.t(), keyword()}

  @type result :: :ok | {:error, term()}

  defmacro __using__(_) do
    quote do
      @behaviour Exenv.Adapter

      @doc false
      def start_link(_opts) do
        :ignore
      end

      @doc false
      def child_spec(config) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [config]}
        }
      end

      @doc false
      def load(_opts) do
        {:error, :not_implemented}
      end

      defoverridable Exenv.Adapter
    end
  end
end
