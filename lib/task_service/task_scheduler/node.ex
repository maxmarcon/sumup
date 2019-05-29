defmodule TaskService.TaskScheduler.Node do
  defstruct blocks: [], task: nil, blocked_by_cnt: 0

  alias __MODULE__
  alias TaskService.Task

  @type t :: %Node{blocks: [binary()], task: %Task{}}
end
