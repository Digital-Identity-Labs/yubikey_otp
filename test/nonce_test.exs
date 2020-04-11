defmodule NonceTest do
  use ExUnit.Case
  #doctest YubikeyOTP.Nonce

  alias YubikeyOTP.Nonce

  describe "generate/0" do

    test "returns a binary string" do
      assert is_binary(Nonce.generate)
    end

    test "returns a nonce 16 or more characters long" do
      assert String.length(Nonce.generate) >= 16
    end

  end


end

