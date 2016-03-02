defmodule Bigflake do
  @moduledoc """
  """

  use GenServer

  alias Bigflake.Minter

  # Client

  @doc """
  Starts the Bigflake server.
  """
  def start_link(worker_id) do
    GenServer.start_link(__MODULE__, worker_id, name: __MODULE__)
  end

  @doc """
  Stops the Bigflake server.
  """
  def stop() do
    GenServer.stop(__MODULE__)
  end

  @doc """
  Mint a new id.
  """
  def mint() do
    GenServer.call(__MODULE__, :mint)
  end

  # Server (callbacks)

  def init(worker_id) do
    state = Minter.initialize_state(worker_id)
    {:ok, state}
  end

  def handle_call(:mint, _from, state) do
    new_timestamp = :os.system_time(:milli_seconds)
    case Minter.mint(new_timestamp, state) do
      {:ok, id, new_state} ->
        {:reply, {:ok, id}, new_state}
      {:error, reason, new_state} ->
        {:reply, {:error, reason}, new_state}
    end
  end
end
