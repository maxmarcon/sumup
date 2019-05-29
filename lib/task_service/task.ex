defmodule TaskService.Task do
  defstruct [:name, :command, requires: []]

  alias __MODULE__

  @type t :: %Task{name: binary(), command: binary(), requires: [binary()]}

  defimpl String.Chars, for: Task do
    def to_string(%Task{command: command}) when not is_nil(command), do: command
    def to_string(%Task{}), do: ""
  end
end
