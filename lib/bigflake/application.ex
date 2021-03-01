defmodule Bigflake.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    worker_id = Application.get_env(:bigflake, :worker_id)

    children = [
      %{id: Bigflake, start: {Bigflake, :start_link, [worker_id]}}
    ]

    opts = [strategy: :one_for_one, name: Bigflake.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
