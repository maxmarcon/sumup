defmodule JobService.Job do
  defstruct [:name, :command, requires: []]

  alias __MODULE__

  @type t :: %Job{name: binary(), command: binary(), requires: [binary()]}

  defimpl String.Chars, for: Job do
    def to_string(%Job{command: command}) when not is_nil(command), do: command
    def to_string(%Job{}), do: ""
  end
end
