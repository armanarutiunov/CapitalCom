defmodule CapitalCom.Orders do
  alias CapitalCom.{Client, Config}

  def list(%Config{} = config) do
    Client.request(config, :get, "/api/v1/workingorders")
  end
end
