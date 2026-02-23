defmodule CapitalComStrategy.Execution do
  alias CapitalComStrategy.Risk

  def submit(order, risk_state, risk_mod \\ CapitalComStrategy.Risk.DefaultPolicy) do
    with :ok <- Risk.allow_order?(risk_mod, order, risk_state) do
      {:ok, %{status: :accepted, order: order}}
    end
  end
end
