defmodule Bigflake.Interface do
  @moduledoc false

  def list_with_mac_address() do
    {:ok, interfaces} = :inet.getifaddrs()

    interfaces
    |> Enum.filter(fn {_iface, opts} -> opts[:hwaddr] && opts[:hwaddr] != [0, 0, 0, 0, 0, 0] end)
    |> Enum.map(fn {iface, opts} -> {List.to_atom(iface), opts[:hwaddr]} end)
  end
end
