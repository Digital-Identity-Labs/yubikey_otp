defmodule YubikeyOTP.Request do
  @moduledoc false

  alias __MODULE__

  @enforce_keys [:id, :otp]

  defstruct [
    :id,
    :secret,
    :otp,
    :timestamp,
    :sl,
    :timeout
  ]

  def new(otp, service) do
    request = %Request{
      id: service.api_id,
      secret: service.api_key,
      otp: otp
    }

    {:ok, request}
  end

  def validate(request) do
    {:ok, request}
  end
end
