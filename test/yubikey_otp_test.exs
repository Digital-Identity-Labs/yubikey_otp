defmodule YubikeyOTPTest do
  use ExUnit.Case
  doctest YubikeyOTP

  @api_id 1

  alias YubikeyOTP.Service

  setup do
    bad_otp = "h=Dfogk5qwCcw6+pr1G64gmomCKgQ=\nt=2020-04-09T09:31:56Z0363\notp=ccccccclulvjgvivliddvvdhdtuculkgikhnrgeueeri\nnonce=vwC1WQd3ip6QLPJfUJji5n\nstatus=BAD_OTP\n\n"

    Tesla.Mock.mock(
      fn
        %{method: :get} ->
          %Tesla.Env{status: 500, body: bad_otp}
      end
    )

#    Query: id: 1
#Query: nonce: njYDJDEARBOFgiJW8b6yIG
#Query: otp: ccccccclulvjgvivliddvvdhdtuculkgikhnrgeuekri
#     Query: timeout: 1
#
    :ok

  end

  describe "device_id/1" do

    test "returns the device ID from a valid OTP string" do
      assert YubikeyOTP.device_id("ccccccbchvthlivuitriujjifivbvtrjkjfirllluurj") == {:ok, "ccccccbchvth"}
    end

    test "returns an error tuple with :otp_invalid error type" do
      assert YubikeyOTP.device_id("ccccccbchvthl") == {:error, :otp_invalid}
    end

  end

  describe "service/1" do

    test "requires an api_id value - returns an error if not supplied" do
      assert YubikeyOTP.service(timestamp: false) == {:error, :service_missing_api_id}
    end

    test "requires an api_id value and returns a service struct if it gets one" do
      assert YubikeyOTP.service(api_id: @api_id) == {:ok, APIResponses.default_service()}
    end
  end

  describe "verify/2" do

    test "immediately returns an error if passed a badly formed OTP" do
      {:ok, service} = YubikeyOTP.service(api_id: @api_id, urls: ["https://api.yubico.com/wsapi/2.0/verify"])
      assert YubikeyOTP.verify("ccccccclulv", service) == {:error, :otp_invalid}
    end

    test "returns an :ok response when passed a valid, fresh OTP" do
      {:ok, service} = YubikeyOTP.service(api_id: @api_id, urls: ["https://api.yubico.com/wsapi/2.0/verify"])
     # assert YubikeyOTP.verify("ccccccclulvjgvivliddvvdhdtuculkgikhnrgeuekri", service) == {:ok, :ok}
    end

#    test "returns an error if passed a replayed OTP" do
#      {:ok, service} = YubikeyOTP.service(api_id: @api_id, urls: ["https://api.yubico.com/wsapi/2.0/verify"])
#      assert YubikeyOTP.verify("ccccccclulvjgvivliddvvdhdtuculkgikhnrgeuekri", service) == {:error, :replayed_otp}
#    end

    test "returns an error if passed a false OTP" do
      {:ok, service} = YubikeyOTP.service(api_id: @api_id, urls: ["https://api.yubico.com/wsapi/2.0/verify"])
      assert YubikeyOTP.verify("ccccccclulvzzzzzzzzzzzzzzzzzzzzzzzzz", service) == {:error, :bad_otp}
    end


  end

end
