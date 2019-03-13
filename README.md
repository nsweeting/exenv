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
    {:exenv, "~> 0.3"}
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

We can pass configuration options to `Exenv` from application config.

```elixir
config :exenv, [
  adapters: [
    {Exenv.Adapters.Dotenv, [file: "path/to/.env"]}
  ]
]
```

You can also run `Exenv` via your own supervision tree. In this case, you must instruct
`Exenv` not to start itself.

```elixir
config :exenv, start_on_application: false
```

Which allows you to add `Exenv` to your own application.

```elixir
defmodule MySupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Exenv, [adapters: [{Exenv.Adapters.Dotenv, [file: "path/to/.env"]}]]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
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

You must then manually load all env vars from your defined adapters:

```elixir
Exenv.load()
```

## Encryption

Exenv has secrets encryption out of the box. Support will depend on the whether
the adapter provides it. Using secrets encryption allows you to keep an encrypted
version of your secrets checked into your repository. As long as the master key
is accessible, these secrets can then be decrypted.

To get started with secrets encryption, first generate a master key.

```bash
mix exenv.master_key /config/master.key
```

This will generate a new master key at `/config/master.key`. You can then encrypt
your secrets file.

```bash
mix exenv.encrypt /config/master.key /config/.env
```

This will encrypt the contents of `/config/.env` using `/config/master.key`. A new
file will then be generated at `/config/.env.enc` with your encrypted secrets.

You must then provide the proper options to your adapters to enable encryption.

```elixir
{Exenv.Adapters.Dotenv, [file: "path/to/.env.enc", encryption: true]}
```

The above will attempt to decrypt `"path/to/.env.enc"` using the contents of the
`"MASTER_KEY"` env var. Alternatively, you can also provide a direct path to the
master key file.

```elixir
{Exenv.Adapters.Dotenv, [file: "path/to/.env.enc", encryption: [master_key: "path/to/master.key"]]}
```

To edit your secrets, you just need to decrypt the original encrypted secrets, and
rencrypt the edited file.

```bash
mix exenv.decrypt /config/master.key /config/.env.enc

## Add to file

mix exenv.encrypt /config/master.key /config/.env
```
