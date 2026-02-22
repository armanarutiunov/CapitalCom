defmodule CapitalCom.RateLimiter do
  use GenServer
  alias CapitalCom.Error

  @session_interval_ms 1000

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  def allow?(api_key, method, route),
    do: GenServer.call(__MODULE__, {:allow?, api_key, method, route})

  @impl true
  def init(_opts), do: {:ok, %{session_post_at_by_api_key: %{}}}

  @impl true
  def handle_call(
        {:allow?, api_key, method, path},
        _from,
        %{session_post_at_by_api_key: session_post_at_by_api_key} = state
      ) do
    if session_create_request?(method, path) and is_binary(api_key) do
      now = System.monotonic_time(:millisecond)
      last = Map.get(session_post_at_by_api_key, api_key)

      if is_nil(last) or now - last >= @session_interval_ms do
        new_state = %{
          state
          | session_post_at_by_api_key: Map.put(session_post_at_by_api_key, api_key, now)
        }

        {:reply, :ok, new_state}
      else
        {:reply,
         {:error,
          Error.new(:rate_limited, "POST /api/v1/session is limited to 1 req/s per api key")},
         state}
      end
    else
      {:reply, :ok, state}
    end
  end

  defp session_create_request?(:post, "/api/v1/session"), do: true
  defp session_create_request?("POST", "/api/v1/session"), do: true
  defp session_create_request?(_, _), do: false
end
