defmodule Bigflake.WorkerId do
  @moduledoc false

  def from(id) when is_integer(id), do: id

  def from(:default_interface) do
    Application.get_env(:bigflake, :interface_module).list_with_mac_address()
    |> Enum.at(0)
    |> mac_address_to_worker_id()
  end

  def from(interface) when is_atom(interface) do
    Application.get_env(:bigflake, :interface_module).list_with_mac_address()
    |> Enum.find(fn {iface, _opts} -> iface == interface end)
    |> mac_address_to_worker_id()
  end

  def from(_) do
    raise ArgumentError,
      message: "expected an integer or an atom representing a network interface"
  end

  def mac_address_to_worker_id({_interface, mac_address}) do
    <<worker_id::48-integer>> = mac_address |> :erlang.list_to_binary()
    worker_id
  end
end
