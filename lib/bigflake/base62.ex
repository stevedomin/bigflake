defmodule Bigflake.Base62 do
  def encode(data, opts \\ []) do
    len = Keyword.get(opts, :length)
    Base62.encode(data) |> with_padding(len)
  end

  def decode(data) do
    data
    |> String.trim_leading("0")
    |> Base62.decode!()
  end

  defp with_padding(data, nil), do: data
  defp with_padding(data, len), do: String.pad_leading(data, len, "0")
end
