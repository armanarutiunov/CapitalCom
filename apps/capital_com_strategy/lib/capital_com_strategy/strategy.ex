defmodule CapitalComStrategy.Strategy do
  @callback init(keyword()) :: {:ok, any()}
  @callback on_market_event(map(), any()) :: {:ok, any()}
  @callback on_fill(map(), any()) :: {:ok, any()}
  @callback on_risk_event(map(), any()) :: {:ok, any()}
end
