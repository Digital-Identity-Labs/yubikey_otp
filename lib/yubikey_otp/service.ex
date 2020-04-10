defmodule YubikeyOTP.Service do
  @moduledoc false

  alias __MODULE__

  @yubico_endpoints [
    "https://api.yubico.com/wsapi/2.0/verify",
    "https://api2.yubico.com/wsapi/2.0/verify",
    "https://api3.yubico.com/wsapi/2.0/verify",
    "https://api4.yubico.com/wsapi/2.0/verify",
    "https://api5.yubico.com/wsapi/2.0/verify"
  ]

  @enforce_keys [:api_id, :urls]

  defstruct [
    :api_key,
    api_id: 0,
    hmac: false,
    urls: @yubico_endpoints,
    timestamp: true,
    timeout: 1000
  ]

  ## A simple merge of options and defaults
  @spec new(options :: map()) :: {:ok, struct()} | {:error, atom()}
  def new(options) do
    {:ok, struct(Service, options)}
  end

  ## We need to make sure the user has actually set their own API ID
  @spec validate(service :: struct()) :: {:ok, struct()} | {:error, :service_missing_api_id}
  def validate(service) do
    if service.api_id == 0 do
      {:error, :service_missing_api_id}
    else
      {:ok, service}
    end
  end
end
