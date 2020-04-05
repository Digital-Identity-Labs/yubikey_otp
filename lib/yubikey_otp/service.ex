defmodule YubikeyOtp.Service do

  @yubico_endpoints [
    "https://api.yubico.com/wsapi/2.0/verify",
    "https://api2.yubico.com/wsapi/2.0/verify",
    "https://api3.yubico.com/wsapi/2.0/verify",
    "https://api4.yubico.com/wsapi/2.0/verify",
    "https://api5.yubico.com/wsapi/2.0/verify",
  ]

  defstruct [
    :api_key,
    :api_id,
    hmac: false,
    urls: @yubico_endpoints,
    timestamp: true,
    timeout: 1000,
  ]

  def validate(service) do
    {:ok, service}
  end

end


