defmodule YubikeyOtp.Response do

  @moduledoc false

  alias __MODULE__
  alias YubikeyOtp.Signature

  @enforce_keys [:otp, :status, :type]

  defstruct [
    :otp,
    :nonce,
    :hmac,
    :timestamp,
    :status,
    :sessioncounter,
    :sessionuse,
    :sl,
    halted: false
  ]

  def new(options \\ %{}) do
    struct(Response, options)
  end

  def validate(response) do
    {:ok, response}
  end

end
