defmodule FakeInterface do
  def list_mac_addresses() do
    [en0: [98, 124, 229, 68, 167, 201], en1: [174, 10, 0, 222, 155, 1]]
  end
end

defmodule FakeInterfaceNull do
  def list_mac_addresses() do
    [
      lo: [0, 0, 0, 0, 0, 0],
      tunl0: [0, 0, 0, 0],
      en0: [98, 124, 229, 68, 167, 201],
      en1: [174, 10, 0, 222, 155, 1]
    ]
  end
end
