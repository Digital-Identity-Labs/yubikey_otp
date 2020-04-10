defmodule YubikeyOTP.HTTP do
  @moduledoc false

  @agent_version "0.1.0"

  alias YubikeyOTP.Nonce
  alias YubikeyOTP.Request
  alias YubikeyOTP.Response
  alias YubikeyOTP.Signature

  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://api.yubico.com/wsapi/2.0/verify")
  plug(Tesla.Middleware.FollowRedirects, max_redirects: 1)
  plug(
    Tesla.Middleware.Headers,
    [
      {
        "user-agent",
        "YubikeyOTP +https://github.com/Digital-Identity-Labs/yubikey_otp YubikeyOTP/#{
          @agent_version
        }"
      }
    ]
  )
  #plug(Tesla.Middleware.Logger)
  plug(Tesla.Middleware.KeepRequest)

  ## Make an API GET request to *one* specified API endpoint URL
  @spec verify(request :: struct(), endpoint :: binary()) :: struct()
  def verify(request, endpoint) do
    case get(endpoint, query: request_to_query(request)) do
      {:ok, %Tesla.Env{status: 200, body: body}} -> process_api_response(endpoint, body)
      {:error, :econnrefused} -> process_error(endpoint, :http_cannot_connect)
      {:ok, http_response} -> parse_http_status(endpoint, http_response)
      {:error, message} -> process_error(endpoint, :http_unknown, message)
    end
  rescue
    e in RuntimeError ->
      process_error(endpoint, :http_cannot_connect, "Could not connect to #{endpoint} API: #{e}")
  end

  ## Build an HTTP GET query string out of the request struct
  @spec request_to_query(request :: struct()) :: map()
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

  ## We don't want empty values in the query string
  @spec filter_nils(map :: map()) :: map()
  defp filter_nils(map) do
    Enum.filter(map, fn {_, v} -> !is_nil(v) end)
    |> Map.new
  end

  ## If it's not a 200-SUCCESS we need to report it
  @spec parse_http_status(endpoint :: binary(), http_response :: any) :: struct()
  defp parse_http_status(endpoint, http_response) do
    case http_response.status do
      404 -> process_error(endpoint, :http_404)
      500 -> process_error(endpoint, :http_500)
      _ -> process_error(endpoint, :http_unknown)
    end
  end

  ## If we get a 200 and a body from the API we can build a response
  @spec process_api_response(endpoint :: binary(), body :: binary()) :: struct()
  defp process_api_response(endpoint, body) do
    body
    |> parse_response_params()
    |> params_to_response(endpoint)
  end

  ## Consistency is the hobgoblin of little minds
  @spec process_error(endpoint :: binary(), code :: atom(), message :: binary()) :: struct()
  defp process_error(endpoint, code, message \\ "") do
    error_to_response(endpoint, code, message)
  end

  ## Turn the Yubicloud response body into a map
  @spec parse_response_params(body :: binary()) :: map()
  defp parse_response_params(body) do
    body
    |> String.trim()
    |> String.split()
      # credo:disable-for-next-line
    |> Enum.map(fn line -> String.split(line, "=", parts: 2) end)
    |> Enum.into(%{}, fn [k, v] -> {k, v} end)
  end

  ## turn the API params map into a record
  @spec params_to_response(params :: map(), endpoint :: binary()) :: struct()
  defp params_to_response(params, endpoint) do
    Response.new(
      url: endpoint,
      halted: false,
      otp: params["otp"],
      nonce: params["nonce"],
      hmac: params["h"],
      timestamp: params["t"],
      status:
        params["status"]
        |> String.downcase()
        |> String.to_atom()
    )
  end

  ## Return errors are responses too
  @spec error_to_response(endpoint :: binary(), code :: atom(), message :: binary()) :: struct()
  defp error_to_response(endpoint, code, message) do
    Response.new(
      url: endpoint,
      halted: true,
      otp: "error",
      nonce: "error",
      message: message,
      hmac: nil,
      timestamp:
        DateTime.utc_now()
        |> DateTime.to_string(),
      status: code
    )
  end
end
