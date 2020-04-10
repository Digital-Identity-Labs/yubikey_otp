defmodule YubikeyOTP.Otp do
  @moduledoc false

  ## Slice the device ID string off the front of the OTP
  @spec device_id(otp :: binary()) :: binary()
  def device_id(otp) do
    otp
    |> String.replace_trailing(String.slice(otp, -32..64), "")
  end

  ## Normalise and check the OTP (mostly by size - the character set can vary)
  @spec validate(otp :: binary()) :: {:ok, binary()} | {:error, :otp_invalid}
  def validate(otp) do
    otp =
      otp
      |> String.trim()
      |> String.downcase()

    if String.valid?(otp) and String.length(otp) >= 32 and String.length(otp) <= 48 do
      {:ok, otp}
    else
      {:error, :otp_invalid}
    end
  end
end
