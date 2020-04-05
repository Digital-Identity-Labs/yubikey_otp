defmodule YubikeyOtp.Http do

  alias __MODULE__
  alias YubikeyOtp.Signature
  alias YubikeyOtp.Request
  alias YubikeyOtp.Response
  alias YubikeyOtp.Nonce

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.yubico.com/wsapi/2.0/verify"
  plug Tesla.Middleware.FollowRedirects, max_redirects: 1
  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.KeepRequest
  plug Tesla.Middleware.Retry,
       delay: 100,
       max_retries: 1,
       max_delay: 2_000,
       should_retry: fn
         {:ok, %{status: status}} when status in [400, 500] -> true
         {:ok, _} -> false
         {:error, _} -> true
       end

  def verify(request, endpoint) do
    try do
      case get(endpoint, query: request_to_query(request)) do
        {:ok, %Tesla.Env{status: 200, body: body} = http_response} -> process_api_response(body)
        {:ok, http_response} -> parse_tesla_failed(endpoint, http_response)
        {:error, message} -> {:error, message}
        _ ->
          {:error, "An unknown HTTP API error occurred"}
      end
    rescue
      e in RuntimeError -> {:error, "Could not connect to #{endpoint} API: #{e}"}
    end
  end

  defp request_to_query(request) do
    %{
      id: request.id,
      otp: request.otp,
      h: nil,
      timestamp: request.timestamp,
      nonce: Nonce.generate(),
      timeout: 1
    }
    |> filter_nils()
  end

  def filter_nils(map) do
    Enum.filter(map, fn {k, v} -> !is_nil(v) end)
  end

  def parse_tesla_failed(endpoint, http_response) do
    {:error, "Could not connect to #{endpoint} API: #{http_response.status}"}
  end

  def process_api_response(body) do
    body
    |> parse_response_params()
    |> params_to_response()
  end

  def parse_response_params(body) do
    body
    |> String.strip()
    |> String.split()
    |> Enum.map(fn line -> String.split(line, "=", parts: 2) end)
    |> Enum.map(fn [k, v] -> {k, v} end)
    |> Enum.into(%{})
  end

  def params_to_response(params) do

    Response.new(
      otp: params["otp"],
      nonce: params["nonce"],
      hmac: params["h"],
      timestamp: params["t"],
      status: params["status"]
              |> String.downcase()
              |> String.to_atom
    )

  end

end