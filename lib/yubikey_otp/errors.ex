defmodule YubikeyOtp.Errors do

  @moduledoc """
    This module should contain all the errors that can be returned by Yubikey OTP, with descriptions.

  """

  @errors %{
    ok: "The OTP is valid",
    bad_otp: "The OTP is invalid format",
    replayed_otp: "The OTP has already been seen by the service",
    bad_signature: "The HMAC signature verification failed",
    missing_parameter: "The request lacks a parameter",
    no_such_client: "The request id does not exist",
    operation_not_allowed: "The request id is not allowed to verify OTPs",
    backend_error: "Unexpected error in our server. Please contact us if you see this error",
    not_enough_answers: "Server could not get requested number of syncs during before timeout",
    replayed_request: "Server has seen the OTP/Nonce combination before",
    http_500: "A low level error has occured on the server",
    http_404: "The API endpoint cannot be found",
    http_unknown: "An unknown HTTP API error occurred",
    http_cannot_connect: "Client cannot connect to server at all",
    otp_invalid: "The supplied OTP is invalid",
  }

  def list do
    Map.keys(@errors)
  end

  def describe(code) do
    @errors[code] || "Unknown error type"
  end

end
