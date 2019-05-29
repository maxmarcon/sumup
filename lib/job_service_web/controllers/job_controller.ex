defmodule JobServiceWeb.JobController do
  use JobServiceWeb, :controller

  alias JobService.JobScheduler
  alias JobService.JobScheduler.Error, as: SchedulerError
  alias JobService.Job

  require Logger

  @format_error "tasks may only contains the 'command' and 'name' keys"

  action_fallback JobServiceWeb.FallbackController

  def schedule(conn, %{"tasks" => tasks}) when is_list(tasks) do
    try do
      task_list =
        tasks
        |> Enum.map(&to_atom_map/1)
        |> Enum.map(&struct!(Job, &1))

      render(conn, "schedule.json", jobs: JobScheduler.compute_schedule(task_list))
    rescue
      ArgumentError ->
        {:error, :bad_request, @format_error}

      KeyError ->
        {:error, :bad_request, @format_error}

      e in SchedulerError ->
        {:error, :bad_request, e.message}
    end
  end

  def schedule(conn, %{"tasks" => _}) do
    {:error, :bad_request, "tasks must be a list"}
  end

  defp to_atom_map(task) when is_map(task) do
    Enum.reduce(task, %{}, fn {k, v}, res -> Map.put(res, String.to_atom(k), v) end)
  end
end
