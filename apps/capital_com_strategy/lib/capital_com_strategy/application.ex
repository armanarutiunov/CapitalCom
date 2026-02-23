defmodule CapitalComStrategy.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [{CapitalComStrategy.Runtime, []}]
    Supervisor.start_link(children, strategy: :one_for_one, name: CapitalComStrategy.Supervisor)
  end
end
