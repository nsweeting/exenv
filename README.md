# Exenv

[![Build Status](https://travis-ci.org/nsweeting/exenv.svg?branch=master)](https://travis-ci.org/nsweeting/exenv)
[![Exenv Version](https://img.shields.io/hexpm/v/exenv.svg)](https://hex.pm/packages/exenv)

Exenv provides an adapter-based solution to loading environment variables from
external sources.

It comes with the following adapter:

* `Exenv.Adapters.Dotenv` (load from .env files)

But has support from external adapters as well:

* [Exenv.Adapters.YAML](https://github.com/nsweeting/exenv_yaml) (load from .yml files)

## Installation

This package can be installed by adding `exenv` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exenv, "~> 0.2"}
  ]
end
```

## Documentation

Please see [HexDocs](https://hexdocs.pm/exenv/Exenv.html#content) for additional
documentation. This readme provides a brief overview, but it is recommended that
the docs are used.

## Getting Started

If all you want is to load a `.env` file on application start - then you're already
done! Out of the box, `Exenv` is configured to start itself with the `Exenv.Adapters.Dotenv`
adapter configured with sane defaults. This means autoloading on application start - with
the `.env` file required to be within your projects root directory.

## Configuration

If you need finer grained control of things, `Exenv` provides extensive config mechansims.

If you do not want `Exenv` to start on application start, simply add the following line to
you `config.exs` file.

```elixir
config :exenv, start_on_application: false
```

If you choose to do the above, you will be responsble for adding `Exenv` to your own
supervision tree.

```elixir
defmodule MySupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Exenv, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

We can pass configuration options to `Exenv` from application config, or directly
from the `child_spec/1` callback.

```elixir
config :exenv, [
  start_on_application: false,
  adapters: [
    {Exenv.Adapters.Dotenv, [file: "path/to/.env"]}
  ]
]
```

```elixir
children = [
  {Exenv, [adapters: [{Exenv.Adapters.Dotenv, [file: "path/to/.env"]}]]}
]

Supervisor.init(children, strategy: :one_for_one)
```

Options passed to the `child_spec/1` callback take precedence over any application
config.

By default, all adapters will autoload their environment vars when `Exenv` starts up.
You can override this behaviour on a per-adapter basis, by simply passing the
`autoload: false` key within your adapter config.

```elixir
[
  adapters: [
    {Exenv.Adapters.Dotenv, [autoload: false, file: "path/to/.env"]}
  ]
]
```

You can then manually load all env vars from your defined adapters:

```elixir
Exenv.load()
```
