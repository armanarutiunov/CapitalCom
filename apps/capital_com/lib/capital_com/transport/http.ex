defmodule CapitalCom.Transport.HTTP do
  alias CapitalCom.{Config, Error}

  @callback request(Config.t(), atom(), String.t(), map() | nil) :: {:ok, map()} | {:error, Error.t()}

  def request(%Config{} = _config, method, path, body) do
    {:ok, %{method: method, path: path, body: body}}
  end
end
