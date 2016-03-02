defmodule Mix.Tasks.Profile do
  @shortdoc "Profile using ExProf"
  use Mix.Task
  import ExProf.Macro

  def run(_args) do
    {:ok, pid} = Bigflake.start_link(0)
    profile do: do_work(pid)
  end

  defp do_work(pid) do
    {:ok, _} = GenServer.call(pid, :mint)
    :ok
  end
end
