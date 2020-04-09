defmodule YubikeyOTP.Service do

  @moduledoc false

  alias __MODULE__

  @yubico_endpoints [
    "https://api.yubico.com/wsapi/2.0/verify",
    "https://api2.yubico.com/wsapi/2.0/verify",
    "https://api3.yubico.com/wsapi/2.0/verify",
    "https://api4.yubico.com/wsapi/2.0/verify",
    "https://api5.yubico.com/wsapi/2.0/verify",
  ]

  @enforce_keys [:api_id, :urls]

  defstruct [
    :api_key,
    api_id: 0,
    hmac: false,
    urls: @yubico_endpoints,
    timestamp: true,
    timeout: 1000,
  ]

  def new(options) do
    {:ok, struct(Service, options)}
  end

  def validate(service) do
    if service.api_id == 0 do
      {:error, :service_missing_api_id}
    else
      {:ok, service}
    end
  end

end
