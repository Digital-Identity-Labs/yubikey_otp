defmodule ServiceTest do
  use ExUnit.Case
  #doctest YubikeyOTP.Service

  alias YubikeyOTP.Service

  describe "new/1" do

    test "returns a service struct" do
      assert {:ok, %Service{api_id: _id, urls: _urls}} = Service.new
    end

    test "can set API key" do
      assert {:ok, %Service{api_id: 808}} = Service.new(api_id: 808)
    end

  end

  describe "validate/1" do

    test "returns error if the API ID is not set to > 0" do
      {:ok, service} = Service.new()
      assert Service.validate(service) == {:error, :service_missing_api_id}
    end

end

end

