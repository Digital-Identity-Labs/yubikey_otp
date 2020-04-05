defmodule YubikeyOtp.Response do

  alias __MODULE__
  alias YubikeyOtp.Signature

  @enforce_keys [:otp, :status]

  defstruct [
    :otp,
    :nonce,
    :hmac,
    :timestamp,
    :status,
    :sessioncounter,
    :sessionuse,
    :sl,
  ]

  def new(options \\ %{}) do
    struct(Response, options)
  end

  def validate(response) do
    {:ok, response}
  end

  def error(response) do
    {:error, "FIXME"}
  end

end