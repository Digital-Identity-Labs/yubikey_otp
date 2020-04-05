defmodule YubikeyOtp do

  @default_service %YubikeyOtp.Service{}

  alias YubikeyOtp.Request
  alias YubikeyOtp.Controller

  def verify(otp) do
    verify(otp, @default_service)
  end

  def verify(otp, service) do
    with {:ok, request} <- Request.new(otp, service),
         {:ok, request} <- Request.validate(request)
      do

      request
      |> Controller.verify(service)
      #|> Response.success()

    else
      err -> Response.error(err)
    end

  end





end
