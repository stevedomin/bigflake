defmodule Bigflake.Base62Test do
  use ExUnit.Case, async: true

  import Bigflake.Base62

  test "encode" do
    assert encode(1) == "1"
    assert encode(9) == "9"
    assert encode(10) == "A"
    assert encode(35) == "Z"
    assert encode(36) == "a"
    assert encode(61) == "z"
    assert encode(62) == "10"
    assert encode(99) == "1b"
    assert encode(3844) == "100"
    assert encode(3860) == "10G"
    assert encode(4815162342) == "5Frvgk"
    assert encode(9223372036854775807) == "AzL8n0Y58m7"
  end

  test "encode with padding" do
    assert encode(1, length: 10) == "0000000001"
    assert encode(9, length: 10) == "0000000009"
    assert encode(10, length: 10) == "000000000A"
    assert encode(35, length: 10) == "000000000Z"
    assert encode(36, length: 10) == "000000000a"
    assert encode(61, length: 10) == "000000000z"
    assert encode(62, length: 10) == "0000000010"
    assert encode(99, length: 10) == "000000001b"
    assert encode(3844, length: 10) == "0000000100"
    assert encode(3860, length: 10) == "000000010G"
    assert encode(4815162342, length: 10) == "00005Frvgk"
    assert encode(9223372036854775807, length: 20) == "000000000AzL8n0Y58m7"
  end

  test "decode" do
    assert decode("1") == 1
    assert decode("9") == 9
    assert decode("A") == 10
    assert decode("Z") == 35
    assert decode("a") == 36
    assert decode("z") == 61
    assert decode("10") == 62
    assert decode("1b") == 99
    assert decode("100") == 3844
    assert decode("10G") == 3860
    assert decode("5Frvgk") == 4815162342
    assert decode("AzL8n0Y58m7") == 9223372036854775807
  end

  test "decode with padding" do
    assert decode("0000000001") == 1
    assert decode("0000000009") == 9
    assert decode("000000000A") == 10
    assert decode("000000000Z") == 35
    assert decode("000000000a") == 36
    assert decode("000000000z") == 61
    assert decode("0000000010") == 62
    assert decode("000000001b") == 99
    assert decode("0000000100") == 3844
    assert decode("000000010G") == 3860
    assert decode("00005Frvgk") == 4815162342
    assert decode("000000000AzL8n0Y58m7") == 9223372036854775807
  end
end
