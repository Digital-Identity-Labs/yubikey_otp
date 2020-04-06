defmodule YubikeyOtp.Http do

  alias __MODULE__
  alias YubikeyOtp.Signature
  alias YubikeyOtp.Request
  alias YubikeyOtp.Response
  alias YubikeyOtp.Nonce

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.yubico.com/wsapi/2.0/verify"
  plug Tesla.Middleware.FollowRedirects, max_redirects: 1
  #plug Tesla.Middleware.Logger
  plug Tesla.Middleware.KeepRequest
#  plug Tesla.Middleware.Retry,
#       delay: 100,
#       max_retries: 1,
#       max_delay: 2_000,
#       should_retry: fn
#         {:ok, %{status: status}} when status in [400, 500] -> true
#         {:ok, _} -> false
#         {:error, _} -> true
#       end

  def verify(request, endpoint) do
    try do
      case get(endpoint, query: request_to_query(request)) do
        {:ok, %Tesla.Env{status: 200, body: body} = http_response} -> process_api_response(body)
        {:error, :econnrefused} -> process_error(endpoint, :http_cannot_connect)
        {:ok, http_response} -> parse_http_status(endpoint, http_response)
        {:error, message} -> process_error(endpoint, :http_unknown, message)
        _ ->
          process_error(endpoint, :http_unknown)
      end
    rescue
      e in RuntimeError -> process_error(endpoint, :http_cannot_connect, "Could not connect to #{endpoint} API: #{e}")
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

  defp filter_nils(map) do
    Enum.filter(map, fn {k, v} -> !is_nil(v) end)
  end

  defp parse_http_status(endpoint, http_response) do
    case http_response.status do
      "404" -> process_error(endpoint, :http_404)
      "500" -> process_error(endpoint, :http_500)
      _ -> process_error(endpoint, :http_unknown)
    end
  end

  defp process_api_response(body) do
    body
    |> parse_response_params()
    |> params_to_response()
  end

  defp process_error(endpoint, code, message \\ "") do
    error_to_response(endpoint, code, message)
  end

  defp parse_response_params(body) do
    body
    |> String.strip()
    |> String.split()
    |> Enum.map(fn line -> String.split(line, "=", parts: 2) end)
    |> Enum.map(fn [k, v] -> {k, v} end)
    |> Enum.into(%{})
  end

  defp params_to_response(params) do

    Response.new(
      halted: false,
      otp: params["otp"],
      nonce: params["nonce"],
      hmac: params["h"],
      timestamp: params["t"],
      status: params["status"]
              |> String.downcase()
              |> String.to_atom
    )

  end

  defp error_to_response(endpoint, code, message \\ nil) do
    Response.new(
      halted: true,
      otp: "error",
      nonce: "error",
      hmac: nil,
      timestamp: DateTime.utc_now
                 |> DateTime.to_string(),
      status: code
    )
  end

end