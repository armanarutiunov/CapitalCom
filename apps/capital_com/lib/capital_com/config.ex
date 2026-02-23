defmodule CapitalCom.Config do
  @enforce_keys [:api_key, :identifier, :password]
  @type t :: %__MODULE__{
    api_key: String.t(),
    identifier: String.t(),
    password: String.t(),
    host: String.t(),
    stream_host: String.t(),
    mode: :live | :demo,
    timeout_ms: pos_integer()
  }

  defstruct [
    :api_key,
    :identifier,
    :password,
    host: "https://api-capital.backend-capital.com",
    stream_host: "wss://api-streaming-capital.backend-capital.com/connect",
    mode: :live,
    timeout_ms: 15_000
  ]
end
