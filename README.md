# Bigflake

[![Build Status](https://travis-ci.org/stevedomin/bigflake.svg?branch=master)](https://travis-ci.org/stevedomin/bigflake)

128-bit, k-ordered, conflict-free IDs in Elixir.

This implementation draws heavily on [Matt Heath's Kāla](https://github.com/mattheath/kala) project, as well as the
[Boudary's flake](https://github.com/boundary/flake).

The IDs it generates consist of:
- timestamp (64-bit): milliseconds since epoch
- worker id (48-bit): an integer or the MAC-address from a device
- sequence number (16-bit): an integer, incremented for each ID requested on the same millisecond

## Installation

This package can be installed by:

  1. Adding bigflake to your list of dependencies in `mix.exs`:

        def deps do
          [{:bigflake, "~> 0.0.1"}]
        end

  2. Ensuring bigflake is started before your application:

        def application do
          [applications: [:bigflake]]
        end

## Usage

```elixir
# generate an id
iex(1)> Bigflake.mint()
{:ok, 26868369774934248202951567081472}
```

You can configure Bigflake to use an integer or a 48-bit MAC address as a worker id.
By default it will use the MAC address of the first device it finds.

```elixir
# config/config.exs
config :bigflake, worker_id: :en1
```

## Using with Ecto

```elixir
# user.ex
defmodule User do
  use Ecto.Schema

  @primary_key {:id, Bigflake.Ecto.UUID, autogenerate: true}

  schema "users" do
    field :name, :string
    field :email, :string

    timestamps
  end
end
```

## Benchmarks

(Results from a MBP i7 2.5Ghz)

```
mint ids     1000000   2.78 µs/op
```

## LICENSE

See [LICENSE](https://github.com/stevedomin/bigflake/blob/master/LICENSE)
