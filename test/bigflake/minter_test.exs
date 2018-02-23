defmodule MinterTest do
  use ExUnit.Case, async: true
  use Bitwise

  alias Bigflake.Minter

  setup do
    state = %{
      last_timestamp: nil,
      sequence: 0,
      worker_id: 1,
      sequence_bits: 12,
      worker_id_bits: 10,
      max_sequence: 100,
      max_worker_id: 100
    }

    {:ok, state: state}
  end

  test "mint with invalid worker id", %{state: state} do
    new_timestamp = :os.system_time(:milli_seconds)

    assert {:error, :worker_id_overflow, _state} =
             Minter.mint(new_timestamp, %{state | worker_id: 101})
  end

  test "mint with backward timestamp", %{state: state} do
    new_timestamp = :os.system_time(:milli_seconds)
    last_timestamp = new_timestamp + 5000

    assert {:error, :time_moved_backwards, _state} =
             Minter.mint(new_timestamp, %{state | last_timestamp: last_timestamp})
  end

  test "mint with timestamp before epoch", %{state: state} do
    new_timestamp = -10
    assert {:error, :time_before_epoch, _state} = Minter.mint(new_timestamp, state)
  end

  test "mint with sequence overflow", %{state: state} do
    new_timestamp = :os.system_time(:milli_seconds)
    state = %{state | sequence: 99, last_timestamp: new_timestamp}
    assert {:ok, _id, new_state} = Minter.mint(new_timestamp, state)
    assert {:error, :sequence_overflow, _state} = Minter.mint(new_timestamp, new_state)
  end

  @test_cases [
    # Plain bit shift 22
    {1_397_666_977_000, 0, 0, 5_862_240_192_299_008_000},
    # Plain bit shift 22
    {2_344_466_898_000, 0, 0, 9_833_406_888_148_992_000},
    # Worker 10
    {1_397_666_977_000, 10, 0, 5_862_240_192_299_048_960},
    # Worker 10
    {2_344_466_898_000, 10, 0, 9_833_406_888_149_032_960},
    # Worker 1023
    {1_397_666_977_000, 1023, 0, 5_862_240_192_303_198_208},
    # Worker 1023
    {2_344_466_898_000, 1023, 0, 9_833_406_888_153_182_208},
    # Worker 10 & Sequence 123
    {1_397_666_977_000, 10, 123, 5_862_240_192_299_049_083},
    # Worker 10 & Sequence 1230
    {2_344_466_898_000, 10, 1230, 9_833_406_888_149_034_190},
    # Worker 10 & Sequence 2356
    {1_397_666_977_000, 10, 2356, 5_862_240_192_299_051_316},
    # Worker 10 & Sequence 4090
    {2_344_466_898_000, 10, 4090, 9_833_406_888_149_037_050}
  ]

  test "to_id" do
    for {last_timestamp, worker_id, sequence, bigflake} <- @test_cases do
      assert bigflake == Minter.to_id(last_timestamp, sequence, worker_id, 12, 10)
    end
  end

  test "ksortability" do
    state = Minter.initialize_state(10)

    {original_ids, _state} =
      Enum.map_reduce(0..10_000_000, state, fn _i, state ->
        new_timestamp = :os.system_time(:milli_seconds) + 10
        {:ok, id, new_state} = Minter.mint(new_timestamp, state)
        {id, new_state}
      end)

    lexical_ids = Enum.sort(original_ids)
    assert original_ids == lexical_ids
  end
end
