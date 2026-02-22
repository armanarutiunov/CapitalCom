defmodule CapitalComTest do
  use ExUnit.Case

  alias CapitalCom.{Config, RateLimiter, Trading}

  test "session route is rate limited at 1 req/s" do
    assert :ok = RateLimiter.allow?("/api/v1/session")
    assert {:error, :rate_limited} = RateLimiter.allow?("/api/v1/session")
  end

  test "order request validates size" do
    cfg = %Config{api_key: "k", identifier: "i", password: "p"}
    req = %Trading.PlaceOrderRequest{epic: "EURUSD", direction: :buy, size: -1}

    assert {:error, %CapitalCom.Error{type: :validation}} = Trading.place_order(cfg, req)
  end

  test "ws subscription enforces 40 epics" do
    {:ok, pid} = start_supervised({CapitalCom.Transport.WS, []})
    Enum.each(1..40, fn i -> assert :ok = CapitalCom.Transport.WS.subscribe(pid, "EPIC#{i}") end)
    assert {:error, :epic_limit_reached} = CapitalCom.Transport.WS.subscribe(pid, "EPIC41")
  end
end
