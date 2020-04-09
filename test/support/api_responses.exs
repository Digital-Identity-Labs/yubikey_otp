defmodule APIResponses do

  def default_service do
    %YubikeyOTP.Service{
      api_id: 1,
      api_key: nil,
      hmac: false,
      timeout: 1000,
      timestamp: true,
      urls: [
        "https://api.yubico.com/wsapi/2.0/verify",
        "https://api2.yubico.com/wsapi/2.0/verify",
        "https://api3.yubico.com/wsapi/2.0/verify",
        "https://api4.yubico.com/wsapi/2.0/verify",
        "https://api5.yubico.com/wsapi/2.0/verify"
      ]
    }
  end

  def yubicloud do


  end

end

# https://api.yubico.com/wsapi/2.0/verify?otp=vvvvvvcucrlcietctckflvnncdgckubflugerlnr&id=87&timeout=8&sl=50&nonce=askjdnkajsndjkasndkjsnad