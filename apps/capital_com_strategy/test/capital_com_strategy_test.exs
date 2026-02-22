defmodule CapitalComStrategyTest do
  use ExUnit.Case

  test "default risk rejects oversize orders" do
    order = %{size: 11}
    assert {:error, :max_size_breached} = CapitalComStrategy.Execution.submit(order, %{max_size: 10})
  end

  test "portfolio updates long and short fills" do
    p = CapitalComStrategy.Portfolio.apply_fill(%{}, %{epic: "EURUSD", size: 2, direction: :buy})
    p = CapitalComStrategy.Portfolio.apply_fill(p, %{epic: "EURUSD", size: 1, direction: :sell})
    assert p["EURUSD"] == 1
  end

  test "engine modes are available" do
    assert :live = CapitalComStrategy.Engine.Live.mode()
    assert :paper = CapitalComStrategy.Engine.Paper.mode()
    assert :replay = CapitalComStrategy.Engine.Replay.mode()
  end
end
