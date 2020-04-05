defmodule YubikeyOtp.Controller do

  alias __MODULE__
  alias YubikeyOtp.Http
  alias YubikeyOtp.Request
  alias YubikeyOtp.Response

  def verify(request, service) do

    http_request_tasks = Enum.map(service.urls, fn (url) -> Task.async(fn -> Http.verify(request, url) end) end)

    response = parallel_api_calls(http_request_tasks)
               |> sort_responses()
               |> filter_responses()
               |> select_primary_response()

    verify_response(response)

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

  def sort_responses(responses) do
    responses
    |> Enum.sort_by(&(&1.timestamp))
  end

  def filter_responses(responses) do
    responses
  end

  def select_primary_response(responses) do
    case Enum.find(responses, fn r -> r.status == :ok end) do
      %Response{} = response -> response
      _ -> List.first(responses)
    end
  end

  def verify_response(response) do
    cond do
      response.status == :ok -> {:ok, response.status}
      true -> {:error, response.status}
    end
  end

end