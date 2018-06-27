defmodule Exenv.Config do
  @moduledoc false

  @default_config [
    start_on_application: true,
    adapters: [
      {Exenv.Adapters.Dotenv, []}
    ]
  ]

  def get(key, default \\ nil) do
    all() |> Keyword.get(key, default)
  end

  def set(key, val) do
    Application.put_env(:exenv, key, val)
  end

  def all do
    config = :exenv |> Application.get_all_env() |> Keyword.delete(:included_applications)
    Keyword.merge(@default_config, config)
  end
end
