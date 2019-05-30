defmodule TaskService.TaskScheduler.Node do
  @moduledoc """
  struct used to wrap a task for inclusion in the graph used to compute the topological sorting.

  Fields:

  * `task`: the task
  * `blocks`: a list of tasks that are blocked by the task
  * `blocked_by`: how many tasks are currently blocking the task
  """
  defstruct blocks: [], task: nil, blocked_by: 0

  alias __MODULE__
  alias TaskService.Task

  @type t :: %Node{blocks: [binary()], task: %Task{} | nil, blocked_by: integer()}
end
