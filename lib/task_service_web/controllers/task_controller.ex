defmodule TaskServiceWeb.TaskController do
  use TaskServiceWeb, :controller

  alias TaskService.TaskScheduler
  alias TaskService.TaskScheduler.Error, as: SchedulerError
  alias TaskService.Task

  @format_error "tasks may only contains the 'command', 'name', and 'requires' keys"

  @missing_name_error "some tasks don't have a name"

  action_fallback TaskServiceWeb.FallbackController

  def schedule(conn, %{"tasks" => tasks}) when is_list(tasks) do
    try do
      task_list =
        tasks
        |> Enum.map(&to_atom_map/1)
        |> Enum.map(&struct!(Task, &1))

      if Enum.any?(task_list, fn
           %Task{name: nil} -> true
           %Task{name: name} when is_binary(name) and byte_size(name) == 0 -> true
           _ -> false
         end) do
        {:error, :bad_request, @missing_name_error}
      else
        render(conn, :schedule, tasks: TaskScheduler.compute_schedule(task_list))
      end
    rescue
      ArgumentError ->
        {:error, :bad_request, @format_error}

      KeyError ->
        {:error, :bad_request, @format_error}

      e in SchedulerError ->
        {:error, :bad_request, e.message}
    end
  end

  def schedule(_conn, %{"tasks" => _}) do
    {:error, :bad_request, "tasks must be a list"}
  end

  defp to_atom_map(task) when is_map(task) do
    Enum.reduce(task, %{}, fn {k, v}, res -> Map.put(res, String.to_atom(k), v) end)
  end
end
