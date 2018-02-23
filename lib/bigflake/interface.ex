defmodule Bigflake.Interface do
  @moduledoc false

  def list_mac_addresses() do
    {:ok, interfaces} = :inet.getifaddrs()
    Enum.map(interfaces, fn {iface, opts} -> {List.to_atom(iface), opts[:hwaddr]} end)
  end
end
