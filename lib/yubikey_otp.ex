defmodule YubikeyOtp do

  @moduledoc """
      This module contains all the functions you'll need to authenticate Yubikey OTPs.
  """

  alias YubikeyOtp.Otp
  alias YubikeyOtp.Service
  alias YubikeyOtp.Request
  alias YubikeyOtp.Response
  alias YubikeyOtp.Controller

  @spec service(options :: map) :: {:ok, %Service{}}
  def service(options) do
    Service.new(options)
    |> Service.validate()
  end

  @spec device_id(otp :: binary) :: {:ok, binary} | {:error, :otp_invalid}
  def device_id(otp) do
    with {:ok, otp} <- Otp.validate(otp) do
      {:ok, Otp.device_id(otp)}
    else
      err -> err
    end
  end

  @spec verify(otp :: binary, service :: %Service{}) :: {:ok, :ok} | {:error, atom}
  def verify(otp, service) do

    with {:ok, otp} <- Otp.validate(otp),
         {:ok, request} <- Request.new(otp, service),
         {:ok, request} <- Request.validate(request)
      do

      request
      |> Controller.verify(service)
      #|> Response.success()

    else
      err -> err
    end

  end

  @spec verify?(otp :: binary, service :: %Service{}) :: true | false
  def verify?(otp, service) do
    case verify(otp, service) do
      {:ok, _} -> true
      _ -> false
    end
  end

end
