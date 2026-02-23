defmodule CapitalCom.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {CapitalCom.Session, []},
      {CapitalCom.RateLimiter, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CapitalCom.Supervisor)
  end
end
