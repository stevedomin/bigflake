# Bigflake

[![Build Status](https://travis-ci.org/stevedomin/bigflake.svg?branch=master)](https://travis-ci.org/stevedomin/bigflake)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/stevedomin/bigflake.svg)](https://beta.hexfaktor.org/github/stevedomin/bigflake)

128-bit, k-ordered, conflict-free IDs in Elixir.

This implementation draws heavily on [Matt Heath's Kāla](https://github.com/mattheath/kala) project, as well as
[Boudary's flake](https://github.com/boundary/flake).

The IDs it generates consist of:
- timestamp (64-bit): milliseconds since epoch
- worker id (48-bit): an integer or the MAC-address from a device
- sequence number (16-bit): an integer, incremented for each ID requested on the same millisecond

## Installation

This package can be installed by:

  1. Adding bigflake to your list of dependencies in `mix.exs`:

        def deps do
          [{:bigflake, "~> 0.4.0"}]
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

There are several ways you can use Bigflake ids as primary keys in your Ecto schemas.

### Base62-encoded string

```elixir
defmodule Ecto.Bigflake.Base62 do
  @behaviour Ecto.Type

  def type, do: :string

  def cast(string) when is_binary(string), do: {:ok, string}
  def cast(_), do: :error

  def dump(string) when is_binary(string), do: {:ok, string}
  def dump(_), do: :error

  def load(string) when is_binary(string), do: {:ok, string}

  def generate do
    {:ok, id} = Bigflake.mint(:base62, length: 25)
    id
  end

  def autogenerate do
    generate()
  end
end

defmodule User do
  use Ecto.Schema

  @primary_key {:id, Ecto.Bigflake.Base62, autogenerate: true}

  schema "users" do
    field :name, :string
    field :email, :string

    timestamps
  end
end

# priv/repo/migrations/create_user.exs
defmodule Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :string, size: 25, primary_key: true
      add :name, :string
      add :email, :string

      timestamps
    end
  end
end
```

### UUID

```elixir
# This module is entirely based off Ecto.UUID, with the generation functions changed.
# (https://github.com/elixir-lang/ecto/blob/master/lib/ecto/uuid.ex)
defmodule Ecto.Bigflake.UUID do
  @behaviour Ecto.Type

  def type, do: :uuid

  def cast(<< _::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96 >> = u), do: {:ok, u}
  def cast(_), do: :error

  def dump(<< a1, a2, a3, a4, a5, a6, a7, a8, ?-,
              b1, b2, b3, b4, ?-,
              c1, c2, c3, c4, ?-,
              d1, d2, d3, d4, ?-,
              e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12 >>) do
    try do
      << d(a1)::4, d(a2)::4, d(a3)::4, d(a4)::4,
         d(a5)::4, d(a6)::4, d(a7)::4, d(a8)::4,
         d(b1)::4, d(b2)::4, d(b3)::4, d(b4)::4,
         d(c1)::4, d(c2)::4, d(c3)::4, d(c4)::4,
         d(d1)::4, d(d2)::4, d(d3)::4, d(d4)::4,
         d(e1)::4, d(e2)::4, d(e3)::4, d(e4)::4,
         d(e5)::4, d(e6)::4, d(e7)::4, d(e8)::4,
         d(e9)::4, d(e10)::4, d(e11)::4, d(e12)::4 >>
    catch
      :error -> :error
    else
      binary ->
        {:ok, %Ecto.Query.Tagged{type: :uuid, value: binary}}
    end
  end
  def dump(_), do: :error

  @compile {:inline, d: 1}

  defp d(?0), do: 0
  defp d(?1), do: 1
  defp d(?2), do: 2
  defp d(?3), do: 3
  defp d(?4), do: 4
  defp d(?5), do: 5
  defp d(?6), do: 6
  defp d(?7), do: 7
  defp d(?8), do: 8
  defp d(?9), do: 9
  defp d(?A), do: 10
  defp d(?B), do: 11
  defp d(?C), do: 12
  defp d(?D), do: 13
  defp d(?E), do: 14
  defp d(?F), do: 15
  defp d(?a), do: 10
  defp d(?b), do: 11
  defp d(?c), do: 12
  defp d(?d), do: 13
  defp d(?e), do: 14
  defp d(?f), do: 15
  defp d(_),  do: throw(:error)

  def load(<<_::128>> = uuid) do
   {:ok, encode(uuid)}
  end
  def load(<<_::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>> = string) do
    raise "trying to load string UUID as Ecto.Bigflake.UUID: #{inspect string}. " <>
          "Maybe you wanted to declare :uuid as your database field?"
  end
  def load(%Ecto.Query.Tagged{type: :uuid, value: uuid}) do
    {:ok, encode(uuid)}
  end
  def load(_), do: :error

  def generate do
    bingenerate() |> encode()
  end

  def bingenerate() do
    {:ok, id} = Bigflake.mint()
    <<id::128-integer>>
  end

  def autogenerate do
    %Ecto.Query.Tagged{type: :uuid, value: bingenerate()}
  end

  defp encode(<<u0::32, u1::16, u2::16, u3::16, u4::48>>) do
    hex_pad(u0, 8) <> "-" <>
    hex_pad(u1, 4) <> "-" <>
    hex_pad(u2, 4) <> "-" <>
    hex_pad(u3, 4) <> "-" <>
    hex_pad(u4, 12)
  end

  defp hex_pad(hex, count) do
    hex = Integer.to_string(hex, 16)
    lower(hex, :binary.copy("0", count - byte_size(hex)))
  end

  defp lower(<<h, t::binary>>, acc) when h in ?A..?F,
    do: lower(t, acc <> <<h + 32>>)
  defp lower(<<h, t::binary>>, acc),
    do: lower(t, acc <> <<h>>)
  defp lower(<<>>, acc),
    do: acc
end

defmodule User do
  use Ecto.Schema

  @primary_key {:id, Ecto.Bigflake.UUID, autogenerate: true}

  schema "users" do
    field :name, :string
    field :email, :string

    timestamps
  end
end

# priv/repo/migrations/create_user.exs
defmodule Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :email, :string

      timestamps
    end
  end
end
```

## Benchmarks

(Results from a MBP i7 2.5Ghz)

```
mint ids            1000000   2.69 µs/op
mint base62 ids      500000   6.64 µs/op
```

## LICENSE

See [LICENSE](https://github.com/stevedomin/bigflake/blob/master/LICENSE)
