defmodule CapitalComStrategy.Risk do
  @callback allow_order?(map(), map()) :: :ok | {:error, atom()}

  def allow_order?(risk_mod, order, state), do: risk_mod.allow_order?(order, state)
end
