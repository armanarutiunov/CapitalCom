defmodule CapitalCom.Client do
  alias CapitalCom.{Config, Error}
  alias CapitalCom.{RateLimiter, Transport.HTTP}

  @type result(t) :: {:ok, t} | {:error, Error.t()}

  def request(%Config{} = config, method, path, body \\ nil) do
    case RateLimiter.allow?(config.api_key, method, path) do
      :ok ->
        HTTP.request(config, method, path, body)

      {:error, %Error{} = error} ->
        {:error, error}

      {:error, :rate_limited} ->
        {:error, Error.new(:rate_limited, "request was rate limited")}

      {:error, reason} ->
        {:error, Error.new(:rate_limited, "request was rate limited", details: %{reason: reason})}
    end
  end
end
