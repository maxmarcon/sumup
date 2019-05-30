defmodule TaskService.Task do
  @moduledoc """
  struct representing a task with a `name`, a `command`, and a list of required tasks (`requires`)
  """
  defstruct [:name, :command, requires: []]

  alias __MODULE__

  @type t :: %Task{name: binary(), command: binary() | nil, requires: [binary()]}

  defimpl String.Chars, for: Task do
    def to_string(%Task{command: command}) when not is_nil(command), do: command
    def to_string(%Task{}), do: ""
  end
end
