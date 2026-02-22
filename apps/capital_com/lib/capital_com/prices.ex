defmodule CapitalCom.Prices do
  alias CapitalCom.{Client, Config, Error}

  def list(%Config{} = config, epic), do: get(config, epic)

  def get(%Config{} = config, epic) when is_binary(epic) and epic != "" do
    Client.request(config, :get, "/api/v1/prices/#{epic}")
  end

  def get(%Config{}, epic),
    do:
      {:error, Error.new(:validation, "epic must be a non-empty string", details: %{epic: epic})}
end
