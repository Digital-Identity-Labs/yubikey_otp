defmodule YubikeyOTP.OTP.ParseError do
  @moduledoc "Error raised when parsing the OTP failed"
  defexception message: "OTP parsing failed"
end
