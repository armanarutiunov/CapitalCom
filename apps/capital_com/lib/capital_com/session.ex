defmodule CapitalCom.Session do
  use GenServer

  defstruct [:cst, :security_token, :expires_at]

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  def put(tokens), do: GenServer.call(__MODULE__, {:put, tokens})
  def get(), do: GenServer.call(__MODULE__, :get)

  @impl true
  def init(_opts), do: {:ok, %__MODULE__{}}

  @impl true
  def handle_call({:put, attrs}, _from, state) do
    new_state = struct(state, attrs)
    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call(:get, _from, state), do: {:reply, state, state}
end
