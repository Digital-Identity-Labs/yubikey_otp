defmodule OTPTest do
  use ExUnit.Case
  #doctest YubikeyOTP.Nonce

  @good_otp "ccccccclulvjbbhccnndrietjjnkeclcvjgrnhcivtgd"
  @terrible_otp "ccccccclulvjnopenopenoo"

  alias YubikeyOTP.OTP

  describe "device_id/1" do

    test "returns an OK tuple with a binary string if passed a valid OTP" do
      {:ok, id} = OTP.device_id(@good_otp)
      assert is_binary(id)
    end

    test "returns the correct device ID" do
      {:ok, id} = OTP.device_id(@good_otp)
      assert id == "ccccccclulvj"
    end

    test "returns an error tuple with :otp_invalid if passed an invalid OTP" do
      assert OTP.device_id(@terrible_otp) == {:error, :otp_invalid}
    end

  end

  describe "validate/1" do

    test "returns an :OK tuple with a binary string that matches the OTP" do
      {:ok, id} = OTP.validate(@good_otp)
      assert is_binary(id)
      assert id == @good_otp
    end

    test "returns an error tuple with :otp_invalid if passed an invalid OTP" do
      assert OTP.validate(@terrible_otp) == {:error, :otp_invalid}
    end

  end

end


