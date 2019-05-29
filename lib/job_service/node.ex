defmodule JobService.Node do
  defstruct blocks: [], job: nil, blocked_by_cnt: 0

  alias __MODULE__
  alias JobService.Job

  @type t :: %Node{blocks: [binary()], job: %Job{}}
end
