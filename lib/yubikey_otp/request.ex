defmodule YubikeyOTP.Request do
  @moduledoc false

  alias __MODULE__
  alias YubikeyOTP.Service

  @enforce_keys [:id, :otp]

  defstruct [
    :id,
    :secret,
    :otp,
    :timestamp,
    :sl,
    :timeout
  ]

  ## Requests are mostly Service info. Each request is converted into a number of actual HTTP calls with their own info
  @spec new(otp :: binary(), service :: struct()) :: {:ok, struct()} | {:error, atom()}
  def new(otp, service) do
    request = %Request{
      id: service.api_id,
      secret: service.api_key,
      otp: otp
    }

    {:ok, request}
  end

  @spec validate(request :: struct()) :: {:ok, struct()} | {:error, atom()}
  def validate(request) do
    {:ok, request}
  end
end
