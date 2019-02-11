defmodule Exenv.Supervisor do
  @moduledoc false

  use Supervisor

  @spec start_link(keyword()) :: Supervisor.on_start()
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec init(keyword()) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}}
  def init(opts) do
    config = Exenv.Config.all() |> Keyword.merge(opts)
    children = adapter_children(config) ++ [{Exenv.Server, config}]
    sup_opts = [strategy: :one_for_one]

    Supervisor.init(children, sup_opts)
  end

  defp adapter_children(config) do
    Keyword.get(config, :adapters, [])
  end
end
