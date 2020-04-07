defmodule YubikeyOtp.Controller do

  alias __MODULE__
  alias YubikeyOtp.Http
  alias YubikeyOtp.Request
  alias YubikeyOtp.Response

  def verify(request, service) do
    prepare_api_tasks(request, service.urls)
    |> make_concurrent_api_calls()
    |> sort_responses()
    |> select_primary_response()
    |> verify_response()
  end

  def prepare_api_tasks(request, urls) do
    Enum.map(urls, fn (url) -> Task.async(fn -> Http.verify(request, url) end) end)
  end

  def make_concurrent_api_calls(tasks) do
    Task.yield_many(tasks, 4000)
    |> Enum.map(
         fn {task, result} ->
           case result do
             nil ->
               Task.shutdown(task, :brutal_kill)
               task_failure_response(:sys_timeout, "Task shutdown")
             {:exit, reason} ->
               task_failure_response(:sys_exit, reason)
             {:ok, response} ->
               if response.status == :ok do
                 immediately_kill_other_tasks(task, tasks)
                 response
               else
                 response
               end
           end
         end
       )
  end

  def immediately_kill_other_tasks(this_task, all_tasks) do
    all_tasks
    |> Enum.each(fn task -> Task.shutdown(task, :brutal_kill) end)
  end

  def sort_responses(responses) do
    responses
    |> Enum.filter(fn r -> !is_nil(r) end)
    |> Enum.sort_by(&(&1.timestamp))
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

  def task_failure_response(code, message) do
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