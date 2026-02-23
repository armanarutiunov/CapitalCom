defmodule CapitalComStrategy.Risk.DefaultPolicy do
  @behaviour CapitalComStrategy.Risk

  @impl true
  def allow_order?(%{size: size}, %{max_size: max}) when size <= max, do: :ok
  def allow_order?(_order, _state), do: {:error, :max_size_breached}
end
