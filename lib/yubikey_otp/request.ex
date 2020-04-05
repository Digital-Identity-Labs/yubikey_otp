defmodule YubikeyOtp.Request do

  alias __MODULE__
  alias YubikeyOtp.Nonce

  @enforce_keys [:id, :otp]

  defstruct [
    :id,
    :otp,
    :timestamp,
    :sl,
    :timeout,
  ]

  def new(otp, service) do

    request = %Request{
      id: service.api_id,
      otp: otp
    }
    {:ok, request}

  end

  def validate(request) do
    {:ok, request}
  end


end