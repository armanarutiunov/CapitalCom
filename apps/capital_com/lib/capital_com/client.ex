defmodule CapitalCom.Client do
  alias CapitalCom.{Config, Error}
  alias CapitalCom.Transport.HTTP

  @type result(t) :: {:ok, t} | {:error, Error.t()}

  def request(%Config{} = config, method, path, body \\ nil) do
    with :ok <- CapitalCom.RateLimiter.allow?(path) do
      HTTP.request(config, method, path, body)
    end
  end
end
