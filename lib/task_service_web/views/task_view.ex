defmodule TaskServiceWeb.TaskView do
  use TaskServiceWeb, :view
  alias TaskServiceWeb.TaskView
  alias TaskService.Task

  def render("schedule.json", %{tasks: tasks}) do
    render_many(tasks, TaskView, "task.json")
  end

  require Logger

  def render("schedule.txt", %{tasks: tasks}) do
    "#!/usr/bin/env bash\n\n" <>
      Enum.join(render_many(tasks, TaskView, "task.txt"), "\n")
  end

  def render("task.json", %{task: %Task{name: name, command: command}}) do
    %{name: name, command: command}
  end

  def render("task.txt", %{task: task}) do
    String.Chars.to_string(task)
  end
end
