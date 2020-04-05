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
    get(endpoint, query: request_to_query(request))
    |> parse_http_response()

  end

  defp request_to_query(request) do
    %{
      id: request.id,
      otp: request.otp,
      h: nil,
      timestamp: request.timestamp,
      nonce:  Nonce.generate(),
      timeout: 1
    }
    |> filter_nils()
  end

  def filter_nils(map) do
    Enum.filter(map, fn {k, v} -> !is_nil(v) end)
  end


  def parse_http_response({:ok, %Elixir.Tesla.Env{status: 200}} = http_response) do

    Apex.ap http_response
    #    %Response {}
  end

end