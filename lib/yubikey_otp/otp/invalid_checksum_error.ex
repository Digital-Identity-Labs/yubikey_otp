defmodule YubikeyOTP.OTP.InvalidChecksumError do
  @moduledoc "Error raised when the OTP checksum is invalid"
  defexception message: "OTP checksum is invalid"
end
