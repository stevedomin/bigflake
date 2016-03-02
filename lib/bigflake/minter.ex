defmodule Bigflake.Minter do
  @moduledoc false

  use Bitwise

  alias Bigflake.WorkerId

  @default_sequence_bits 16
  @default_worker_id_bits 48

  def initialize_state(worker_id, sequence_bits \\ @default_sequence_bits, worker_id_bits \\ @default_worker_id_bits) do
    %{last_timestamp: 0,
      sequence: 0,
      worker_id: WorkerId.from(worker_id),
      sequence_bits: sequence_bits,
      worker_id_bits: worker_id_bits,
      max_sequence: (1 <<< sequence_bits) - 1,
      max_worker_id: (1 <<< worker_id_bits) - 1}
  end

  def mint(new_timestamp, %{worker_id: worker_id, max_worker_id: max_worker_id} = state) when worker_id < max_worker_id do
    case update(new_timestamp, state) do
      {:ok, new_state} ->
        %{last_timestamp: last_timestamp,
          sequence: sequence,
          worker_id: worker_id,
          sequence_bits: sequence_bits,
          worker_id_bits: worker_id_bits} = new_state
        {:ok, to_id(last_timestamp, sequence, worker_id, sequence_bits, worker_id_bits), new_state}
      {:error, reason} ->
        {:error, reason, state}
    end
  end
  def mint(_new_timestamp, state), do: {:error, :worker_id_overflow, state}

  def to_id(last_timestamp, sequence, worker_id, sequence_bits, worker_id_bits) do
    id_bits = 64 + sequence_bits + worker_id_bits

    <<id::size(id_bits)-integer>> = <<last_timestamp::64-integer,
                                      worker_id::size(worker_id_bits)-integer,
                                      sequence::size(sequence_bits)-integer>>
    id
  end

  defp update(timestamp, %{last_timestamp: last_timestamp}) when last_timestamp != nil and timestamp < last_timestamp do
    {:error, :time_moved_backwards}
  end
  defp update(timestamp, %{last_timestamp: last_timestamp}) when timestamp != last_timestamp and timestamp < 0 do
    {:error, :time_before_epoch}
  end
  defp update(timestamp, %{last_timestamp: last_timestamp} = state) when timestamp != last_timestamp do
    {:ok, %{state | last_timestamp: timestamp, sequence: 0}}
  end
  defp update(_timestamp, %{sequence: sequence, max_sequence: max_sequence}) when sequence + 1 > max_sequence do
    {:error, :sequence_overflow}
  end
  defp update(_timestamp, %{sequence: sequence} = state) do
    {:ok, %{state | sequence: sequence + 1}}
  end
end
