defmodule CapitalCom.General do
  alias CapitalCom.{Client, Config}

  def list(%Config{} = config) do
    Client.request(config, :get, "/api/v1/time")
  end

  def ping(%Config{} = config) do
    Client.request(config, :get, "/api/v1/ping")
  end
end
