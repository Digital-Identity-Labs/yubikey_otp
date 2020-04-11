defmodule ErrorsTest do
  use ExUnit.Case
  #doctest YubikeyOTP.Errors

  @official_error_codes MapSet.new(
                          [
                            :ok,
                            :bad_otp,
                            :replayed_otp,
                            :bad_signature,
                            :missing_parameter,
                            :no_such_client,
                            :operation_not_allowed,
                            :backend_error,
                            :not_enough_answers,
                            :replayed_request,
                          ]
                        )

  @local_error_codes MapSet.new(
                       [
                         :http_500,
                         :http_404,
                         :http_unknown,
                         :http_cannot_connect,
                         :otp_invalid,
                         :service_missing_api_id
                       ]
                     )

  alias YubikeyOTP.Errors

  describe "list/0" do

    test "returns a list that includes all official Yubikey OTP API responses as atoms" do
      assert MapSet.subset?(@official_error_codes, MapSet.new(Errors.list))
    end

    test "returns a list that also includes all library error codes too, as atoms" do
      assert MapSet.subset?(@local_error_codes, MapSet.new(Errors.list))
    end

  end

  describe "describe/1" do

    test "returns the a description for a known error code" do
      assert Errors.describe(:no_such_client) == "The request id does not exist"
    end

    test "returns 'unknown error' for for an unknown error code" do
      assert Errors.describe(:omg) == "Unknown error type"
    end

  end

end

