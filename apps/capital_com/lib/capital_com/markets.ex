defmodule CapitalCom.Markets do
  alias CapitalCom.{Client, Config}

  def list(%Config{} = config) do
    Client.request(config, :get, "/api/v1/markets")
  end
end
