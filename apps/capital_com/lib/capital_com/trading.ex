defmodule CapitalCom.Trading do
  alias CapitalCom.{Client, Config, Error}

  defmodule PlaceOrderRequest do
    @enforce_keys [:epic, :direction, :size]
    defstruct [:epic, :direction, :size]
  end

  def place_order(%Config{} = config, %PlaceOrderRequest{} = request) do
    with :ok <- validate_request(request),
         {:ok, response} <- Client.request(config, :post, "/api/v1/positions", Map.from_struct(request)) do
      {:ok, Map.put(response, :dealReference, "DUMMY-DEAL-REF")}
    end
  end

  def confirm_deal(%Config{} = config, deal_reference) when is_binary(deal_reference) do
    Client.request(config, :get, "/api/v1/confirms/#{deal_reference}")
  end

  defp validate_request(%PlaceOrderRequest{size: size}) when is_number(size) and size > 0, do: :ok
  defp validate_request(_), do: {:error, Error.new(:validation, "order size must be positive")}
end
