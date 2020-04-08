defmodule YubikeyOtpTest do
  use ExUnit.Case
  doctest YubikeyOtp

  describe "device_id/1" do

    test "returns the device ID from a valid OTP string" do
      assert YubikeyOtp.device_id("ccccccbchvthlivuitriujjifivbvtrjkjfirllluurj") == {:ok, "ccccccbchvth"}
    end

    test "returns an error tuple with :otp_invalid error type" do
      assert YubikeyOtp.device_id("ccccccbchvthl") ==  {:error, :otp_invalid}
    end

  end

end
