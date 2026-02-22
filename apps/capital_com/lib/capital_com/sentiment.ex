defmodule CapitalCom.Sentiment do
  alias CapitalCom.{Client, Config, Error}

  def list(%Config{} = config) do
    Client.request(config, :get, "/api/v1/clientsentiment")
  end

  def get(%Config{} = config, market_id) when is_binary(market_id) and market_id != "" do
    Client.request(config, :get, "/api/v1/clientsentiment/#{market_id}")
  end

  def get(%Config{}, market_id),
    do:
      {:error,
       Error.new(:validation, "market_id must be a non-empty string",
         details: %{market_id: market_id}
       )}
end
