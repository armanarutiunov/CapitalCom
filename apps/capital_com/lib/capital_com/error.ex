defmodule CapitalCom.Error do
  @enforce_keys [:type, :message]
  defexception [:type, :message, :details, :status]

  @type t :: %__MODULE__{type: atom(), message: String.t(), details: map() | nil, status: pos_integer() | nil}

  @spec new(atom(), String.t(), keyword()) :: t()
  def new(type, message, opts \\ []) do
    %__MODULE__{type: type, message: message, details: Keyword.get(opts, :details), status: Keyword.get(opts, :status)}
  end
end
