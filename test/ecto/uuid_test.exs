defmodule Ecto.Bigflake.UUIDTest do
  use ExUnit.Case, async: true

  @test_uuid "00000153-29a5-1880-60f8-1dcaf7f40000"
  @test_uuid_binary <<0x00, 0x00, 0x01, 0x53, 0x29, 0xA5, 0x18, 0x80,
                      0x60, 0xF8, 0x1D, 0xCA, 0xF7, 0xF4, 0x00, 0x00>>

  test "cast" do
    assert Ecto.Bigflake.UUID.cast(@test_uuid) == {:ok, @test_uuid}
    assert Ecto.Bigflake.UUID.cast(@test_uuid_binary) == :error
    assert Ecto.Bigflake.UUID.cast(nil) == :error
  end

  test "load" do
    assert Ecto.Bigflake.UUID.load(@test_uuid_binary) == {:ok, @test_uuid}
    assert Ecto.Bigflake.UUID.load("") == :error
    assert_raise RuntimeError, ~r"trying to load string UUID as Ecto.Bigflake.UUID:", fn ->
      Ecto.Bigflake.UUID.load(@test_uuid)
    end
  end

  test "dump" do
    assert Ecto.Bigflake.UUID.dump(@test_uuid) == {:ok, %Ecto.Query.Tagged{value: @test_uuid_binary, type: :uuid}}
    assert Ecto.Bigflake.UUID.dump(@test_uuid_binary) == :error
  end

  test "generate" do
    assert << _::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96 >> = Ecto.Bigflake.UUID.generate
  end
end
