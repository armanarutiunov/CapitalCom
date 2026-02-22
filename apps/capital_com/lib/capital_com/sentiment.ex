defmodule CapitalCom.Sentiment do
  alias CapitalCom.{Client, Config}

  def list(%Config{} = config) do
    Client.request(config, :get, "/api/v1/sentiment")
  end
end
