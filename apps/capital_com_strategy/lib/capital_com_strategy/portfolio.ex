defmodule CapitalComStrategy.Portfolio do
  def apply_fill(portfolio, %{epic: epic, size: size, direction: direction}) do
    signed_size = if direction == :sell, do: -size, else: size
    Map.update(portfolio, epic, signed_size, &(&1 + signed_size))
  end
end
