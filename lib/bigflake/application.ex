defmodule Bigflake.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    worker_id = Application.get_env(:bigflake, :worker_id)

    children = [
      worker(Bigflake, [worker_id])
    ]

    opts = [strategy: :one_for_one, name: Bigflake.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
