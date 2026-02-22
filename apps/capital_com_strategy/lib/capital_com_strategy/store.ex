defmodule CapitalComStrategy.Store do
  @callback put(term(), term()) :: :ok
  @callback get(term()) :: term()
end
