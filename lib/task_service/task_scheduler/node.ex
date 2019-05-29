defmodule TaskService.TaskScheduler.Node do
  defstruct blocks: [], task: nil, blocked_by: 0

  alias __MODULE__
  alias TaskService.Task

  @type t :: %Node{blocks: [binary()], task: %Task{}, blocked_by: integer()}
end
