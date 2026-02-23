defmodule CapitalCom.Auth.Encryption do
  @moduledoc false

  def encode_password(password) when is_binary(password) do
    Base.encode64(password)
  end
end
