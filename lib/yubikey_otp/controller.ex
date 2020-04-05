defmodule YubikeyOtp.Controller do

  alias __MODULE__
  alias YubikeyOtp.Http

  def verify(request, service) do

    http_request_tasks = Enum.map(service.urls, fn (url) -> Task.async(fn -> Http.verify(request, url) end) end)

    parallel_api_calls(http_request_tasks)
#    |> Enum.map(fn http_response -> parse_http_response(http_response) end)

    {:ok, "X"}

  end

  def parallel_api_calls(tasks) do
    Task.yield_many(tasks)
    |> Enum.map(
         fn {task, result} ->
           case result do
             nil ->
               Task.shutdown(task, :brutal_kill)
               exit(:timeout)
             {:exit, reason} ->
               exit(reason)
             {:ok, result} ->
               result
           end
         end
       )
  end


end