defmodule CapitalCom.Accounts do
  alias CapitalCom.{Client, Config}

  def list(%Config{} = config) do
    Client.request(config, :get, "/api/v1/accounts")
  end
end
