defmodule YubikeyOTP do
  @moduledoc """
  YubikeyOTP is an Elixir client for validating Yubikey one-time-passwords. It can validate OTPs using Yubico's public
  API or by using your own or third-party OTP validation services.

  ## Requirements

  This module contains all the functions you'll need to authenticate Yubikey OTPs. You will also need a developer API
  ID (and optionally a shared secret) that can be got from [Yubico](https://upgrade.yubico.com/getapikey/).

  You will obviously need at least one Yubikey that supports the OTP protocol.

  ## Example

      iex> my_id = Application.get_env(:my_app, :yubikey_client_id)
      iex> {:ok, service} = YubikeyOTP.service(api_id: my_id)
      iex> YubikeyOTP.verify("ccccccclzlojikekndkhfibggvkgujttihkcuvkjfrvj", service)
      {:ok, :ok}
      iex> YubikeyOTP.verify("ccccccclzlojikekndkhfibggvkgujttihkcuvkjfrvj", service)
      {:error, :replayed_otp}

  """

  alias YubikeyOTP.Controller
  alias YubikeyOTP.Otp
  alias YubikeyOTP.Request
  alias YubikeyOTP.Response
  alias YubikeyOTP.Service

  @doc """
    Returns a Service structure that defines the API backend to use. Default settings are for the Yubicloud service.

    The only required key is *:api_id*

    You don't need to create this for each request - it can be set as a module attribute.

  ## Example

      iex> {:ok, service} = YubikeyOTP.service(api_id: "65749337983737")
      {:ok,
        %YubikeyOTP.Service{
        api_id: "65749337983737",
        api_key: nil,
        hmac: false,
        timeout: 1000,
        timestamp: true,
        urls: ["https://api.yubico.com/wsapi/2.0/verify",
          "https://api2.yubico.com/wsapi/2.0/verify",
          "https://api3.yubico.com/wsapi/2.0/verify",
          "https://api4.yubico.com/wsapi/2.0/verify",
          "https://api5.yubico.com/wsapi/2.0/verify"]
      }}

    The Yubicloud API has five different endpoint URLs, and by default these are all used concurrently.

  """
  @spec service(options :: map) :: {:ok, %Service{}} | {:error, atom}
  def service(options) do
    with {:ok, service} <- Service.new(options),
         {:ok, service} <- Service.validate(service) do
      {:ok, service}
    else
      err -> err
    end
  end

  @doc """
  Returns the device ID part of a Yubikey OTP

  The first part of a Yubikey OTP is static and identifies the key itself. This ID can be used to match a key with it's
  owner - you don't want to only authenticate the OTP as valid, you also need to check it's the user's Yubikey.

  ## Example

      iex> YubikeyOTP.device_id("ccccccclulvjtugnjuuufuiebhdvucdihnngndtvfjrb")
      {:ok, "ccccccclulvj"}

  """
  @spec device_id(otp :: binary) :: {:ok, binary} | {:error, :otp_invalid}
  def device_id(otp) do
    with {:ok, otp} <- Otp.validate(otp) do
      {:ok, Otp.device_id(otp)}
    else
      err -> err
    end
  end

  @doc """
    Verify a Yubikey OTP using the specified service and return the status

    This will contact the remote backend and process the response.

    A successfully authenticated OTP will result in {:ok, :ok}. A failure will result in an :error tuple containing an
    error code. Most error codes are based on the standard protocol status types and are listed in `YubikeyOTP.Errors`

  ## Example

      iex> YubikeyOTP.verify("ccccccclulvjbthgghkbvvlcludiklkncnecncevcrlg", service)
      {:ok, :ok}
      iex> YubikeyOTP.verify("ccccccclulvjbthgghkbvvlcludiklkncnecncevcrlg", service)
      {:error, :replayed_otp}

  """
  @spec verify(otp :: binary(), service :: %Service{}) :: {:ok, :ok} | {:error, atom()}
  def verify(otp, service) do
    with {:ok, otp} <- Otp.validate(otp),
         {:ok, request} <- Request.new(otp, service),
         {:ok, request} <- Request.validate(request) do
      request
      |> Controller.verify(service)
    else
      err -> err
    end
  end

  @doc """
    Verify a Yubikey OTP using the specified service and return true or false

    This will contact the remote backend and process the response. An authenticated OTP will produce `true`.
    Anything other than a success will be returned as `false`.

  ## Example

      iex> YubikeyOTP.verify?("ccccccclulvjihcchvujedikcndnbuttfutgvbcgblhk", service)
      true
      iex> YubikeyOTP.verify?("ccccccclulvjihcchvujedikcndnbuttfutgvbcgblhk", service)
      false

  """
  @spec verify?(otp :: binary, service :: %Service{}) :: true | false
  def verify?(otp, service) do
    case verify(otp, service) do
      {:ok, :ok} -> true
      {:error, _} -> false
    end
  end
end
