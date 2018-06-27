defmodule Exenv.Supervisor do
  @moduledoc false

  use Supervisor

  alias Exenv.Config

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    config = Config.all() |> Keyword.merge(opts)
    children = adapter_children(config) ++ [{Exenv.Server, config}]
    sup_opts = [strategy: :one_for_one]

    Supervisor.init(children, sup_opts)
  end

  defp adapter_children(config) do
    Keyword.get(config, :adapters, [])
  end
end
