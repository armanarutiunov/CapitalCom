defmodule CapitalCom.General do
  alias CapitalCom.{Client, Config}

  def list(%Config{} = config) do
    Client.request(config, :get, "/api/v1/general")
  end
end
