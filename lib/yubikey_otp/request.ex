defmodule YubikeyOtp.Request do

  alias __MODULE__
  alias YubikeyOtp.Nonce

  @enforce_keys [:id, :otp, :nonce]

  defstruct [
    :id,
    :otp,
    :timestamp,
    :nonce,
    :sl,
    :timeout,
  ]

  def new(otp, service) do

    request = %Request{
      id: service.api_id,
      otp: otp,
      nonce: Nonce.generate()
    }
    {:ok, request}

  end

  def validate(request) do
    {:ok, request}
  end


end