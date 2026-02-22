defmodule CapitalComStrategy.Store.ETS do
  @behaviour CapitalComStrategy.Store

  def table, do: :capital_com_strategy_store

  def init do
    :ets.new(table(), [:named_table, :set, :public])
  rescue
    ArgumentError -> table()
  end

  @impl true
  def put(key, value) do
    :ets.insert(table(), {key, value})
    :ok
  end

  @impl true
  def get(key) do
    case :ets.lookup(table(), key) do
      [{^key, value}] -> value
      _ -> nil
    end
  end
end
