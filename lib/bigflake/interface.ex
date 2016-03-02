defmodule Bigflake.Interface do
  @moduledoc false

  def list_with_mac_address() do
    {:ok, interfaces} = :inet.getifaddrs()
    Enum.filter_map(interfaces,
      fn {_iface, opts} -> opts[:hwaddr] && opts[:hwaddr] != [0,0,0,0,0,0] end,
      fn {iface, opts} -> {List.to_atom(iface), opts[:hwaddr]} end)
  end
end
