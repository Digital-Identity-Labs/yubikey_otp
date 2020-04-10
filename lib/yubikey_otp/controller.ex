defmodule YubikeyOTP.Controller do
  @moduledoc false

  @timeout 4000

  alias YubikeyOTP.HTTP
  alias YubikeyOTP.Response

  ## Make the HTTP calls concurrently, then process the results.
  def verify(request, service) do
    request
    |> prepare_api_tasks(service.urls)
    |> make_concurrent_api_calls()
    |> sort_responses()
    |> select_primary_response()
    |> verify_response()
  end

  ## Generate a list of Agent processes, ready to go, that make the actual HTTP calls
  defp prepare_api_tasks(request, urls) do
    Enum.map(urls, fn url -> Task.async(fn -> HTTP.verify(request, url) end) end)
  end

  ## Fire off the HTTP agents and handle the results
  defp make_concurrent_api_calls(tasks) do
    tasks
    |> Task.yield_many(@timeout)
    |> Enum.map(fn {task, result} ->
      case result do
        nil ->
          Task.shutdown(task, :brutal_kill)
          task_failure_response(:sys_timeout, "Task shutdown")

        {:exit, reason} ->
          task_failure_response(:sys_exit, reason)

        {:ok, response} ->
          task_success_and_completion(response, task, tasks)
      end
    end)
  end

  ## Process any API responses, and maybe try to stop other ongoing requests
  defp task_success_and_completion(response, task, tasks) do

    if response.status == :ok do
      immediately_kill_other_tasks(task, tasks)
    end

    response
  end

  ## In theory this kills any active agents in the list, in reality... maybe not
  defp immediately_kill_other_tasks(_this_task, all_tasks) do
    all_tasks
    |> Enum.each(fn task -> Task.shutdown(task, :brutal_kill) end)
  end

  ## Sort and filter the response structs
  defp sort_responses(responses) do
    responses
    |> Enum.filter(fn r -> !is_nil(r) end)
    |> Enum.sort_by(& &1.timestamp)
  end

  ## Five API calls enter, only one leaves. Hopefully a useful one.
  defp select_primary_response(responses) do
    case Enum.find(responses, fn r -> r.status == :ok end) do
      %Response{} = response -> response
      _ -> List.first(responses)
    end
  end

  ## What actually happened?
  defp verify_response(response) do
    if response.status == :ok do
      {:ok, response.status}
    else
      {:error, response.status}
    end
  end

  ## Make a response out of a low-level HTTP failure
  defp task_failure_response(code, _message) do
    Response.new(
      halted: true,
      otp: "error",
      nonce: "error",
      hmac: nil,
      timestamp:
        DateTime.utc_now()
        |> DateTime.to_string(),
      status: code
    )
  end
end
