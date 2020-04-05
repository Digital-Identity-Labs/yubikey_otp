defmodule YubikeyOtp do

  alias YubikeyOtp.Otp
  alias YubikeyOtp.Service
  alias YubikeyOtp.Request
  alias YubikeyOtp.Response
  alias YubikeyOtp.Controller


  def service(options) do
    Service.new(options)
    |> Service.validate()
  end

  def device_id(otp) do

    with {:ok, otp} <- Otp.validate(otp) do
      Otp.device_id(otp)
    else
      err -> err
    end
  end

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





end
