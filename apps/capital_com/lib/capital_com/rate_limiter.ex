defmodule CapitalCom.RateLimiter do
  use GenServer

  @session_interval_ms 1000

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  def allow?(route), do: GenServer.call(__MODULE__, {:allow?, route})

  @impl true
  def init(_opts), do: {:ok, %{session_at: nil}}

  @impl true
  def handle_call({:allow?, "/api/v1/session"}, _from, %{session_at: last} = state) do
    now = System.monotonic_time(:millisecond)

    if is_nil(last) or now - last >= @session_interval_ms do
      {:reply, :ok, %{state | session_at: now}}
    else
      {:reply, {:error, :rate_limited}, state}
    end
  end

  def handle_call({:allow?, _route}, _from, state), do: {:reply, :ok, state}
end
