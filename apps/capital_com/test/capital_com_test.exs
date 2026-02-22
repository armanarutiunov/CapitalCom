defmodule CapitalComTest do
  use ExUnit.Case

  alias CapitalCom.{Client, Config, Error, General, Orders, Prices, RateLimiter, Sentiment, Trading}

  test "session login is rate limited at 1 req/s per api key" do
    key_a = "k-a-#{System.unique_integer([:positive])}"
    key_b = "k-b-#{System.unique_integer([:positive])}"

    assert :ok = RateLimiter.allow?(key_a, :post, "/api/v1/session")

    assert {:error, %Error{type: :rate_limited}} =
             RateLimiter.allow?(key_a, :post, "/api/v1/session")

    assert :ok = RateLimiter.allow?(key_a, :get, "/api/v1/session")
    assert :ok = RateLimiter.allow?(key_b, :post, "/api/v1/session")
  end

  test "client returns typed rate limit errors" do
    cfg = %Config{
      api_key: "client-#{System.unique_integer([:positive])}",
      identifier: "i",
      password: "p"
    }

    assert {:ok, _} = Client.request(cfg, :post, "/api/v1/session", %{})

    assert {:error, %Error{type: :rate_limited}} =
             Client.request(cfg, :post, "/api/v1/session", %{})
  end

  test "service routes match generated endpoint paths" do
    cfg = %Config{api_key: "k", identifier: "i", password: "p"}

    assert {:ok, %{path: "/api/v1/workingorders"}} = Orders.list(cfg)

    assert {:ok, %{path: "/api/v1/prices/CS.D.EURUSD.CFD.IP"}} =
             Prices.get(cfg, "CS.D.EURUSD.CFD.IP")

    assert {:ok, %{path: "/api/v1/clientsentiment"}} = Sentiment.list(cfg)
    assert {:ok, %{path: "/api/v1/time"}} = General.list(cfg)
    assert {:ok, %{path: "/api/v1/ping"}} = General.ping(cfg)
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

  test "place_order does not inject fake deal reference" do
    cfg = %Config{api_key: "k", identifier: "i", password: "p"}
    req = %Trading.PlaceOrderRequest{epic: "EURUSD", direction: :buy, size: 1}

    assert {:ok, response} = Trading.place_order(cfg, req)
    refute Map.has_key?(response, :dealReference)
  end
end
