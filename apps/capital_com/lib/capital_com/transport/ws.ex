defmodule CapitalCom.Transport.WS do
  use GenServer

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, [])
  def subscribe(pid, epic), do: GenServer.call(pid, {:subscribe, epic})
  def subscriptions(pid), do: GenServer.call(pid, :subscriptions)

  @impl true
  def init(_opts), do: {:ok, %{subs: MapSet.new()}}

  @impl true
  def handle_call({:subscribe, epic}, _from, state) do
    if MapSet.size(state.subs) >= 40 do
      {:reply, {:error, :epic_limit_reached}, state}
    else
      {:reply, :ok, %{state | subs: MapSet.put(state.subs, epic)}}
    end
  end

  def handle_call(:subscriptions, _from, state), do: {:reply, state.subs, state}
end
