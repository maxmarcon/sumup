defmodule TaskService.TaskSchedulerTest do
  alias TaskService.TaskScheduler
  alias TaskService.Task
  alias TaskService.TaskScheduler.Error

  use ExUnit.Case

  @simple_input ~S"""
    {
    "tasks": [{
      "name": "task-1",
      "command": "touch /tmp/file1"
    }, {
      "name": "task-2",
      "command": "cat /tmp/file1",
      "requires": ["task-3"]
    }, {
      "name": "task-3",
      "command": "echo 'Hello World!' > /tmp/file1",
      "requires": ["task-1"]
    }, {
      "name": "task-4",
      "command": "rm /tmp/file1",
      "requires": ["task-2", "task-3"]
    }]
  }
  """

  @with_cycle ~S"""
    {
    "tasks": [{
      "name": "task-1",
      "command": "touch /tmp/file1"
    }, {
      "name": "task-2",
      "command": "cat /tmp/file1",
      "requires": ["task-3"]
    }, {
      "name": "task-3",
      "command": "echo 'Hello World!' > /tmp/file1",
      "requires": ["task-1", "task-4"]
    }, {
      "name": "task-4",
      "command": "rm /tmp/file1",
      "requires": ["task-2", "task-3"]
    }]
  }
  """

  @unknown_requirements ~S"""
    {
    "tasks": [{
      "name": "task-1",
      "command": "touch /tmp/file1"
    }, {
      "name": "task-2",
      "command": "cat /tmp/file1",
      "requires": ["task-3", "task-7"]
    }, {
      "name": "task-3",
      "command": "echo 'Hello World!' > /tmp/file1",
      "requires": ["task-1"]
    }, {
      "name": "task-4",
      "command": "rm /tmp/file1",
      "requires": ["task-2", "task-3"]
    }]
  }
  """

  @duplicate_requirements ~S"""
    {
    "tasks": [{
      "name": "task-1",
      "command": "touch /tmp/file1"
    }, {
      "name": "task-2",
      "command": "cat /tmp/file1",
      "requires": ["task-3"]
    }, {
      "name": "task-3",
      "command": "echo 'Hello World!' > /tmp/file1",
      "requires": ["task-1"]
    }, {
      "name": "task-4",
      "command": "rm /tmp/file1",
      "requires": ["task-2", "task-3", "task-3"]
    }]
  }
  """

  @duplicate_task ~S"""
    {
    "tasks": [{
      "name": "task-1",
      "command": "touch /tmp/file1"
    }, {
      "name": "task-2",
      "command": "cat /tmp/file1",
      "requires": ["task-3"]
    }, {
      "name": "task-3",
      "command": "echo 'Hello World!' > /tmp/file1",
      "requires": ["task-1"]
    }, {
      "name": "task-2",
      "command": "dup",
      "requires": ["task-1"]
    }, {
      "name": "task-4",
      "command": "rm /tmp/file1",
      "requires": ["task-2", "task-3"]
    }]
  }
  """

  def build_tasks(input) do
    input
    |> Jason.decode!(keys: :atoms)
    |> Access.get(:tasks)
    |> Enum.map(&struct!(Task, &1))
  end

  @doc """
  check whether the tasks in the ordered list honour the requirements
  """
  def right_order(ordered_list, input) do
    Enum.each(input, fn %Task{requires: requires, name: name} ->
      pos = Enum.find_index(ordered_list, &(&1.name == name))

      Enum.each(requires, fn req ->
        assert Enum.find_index(ordered_list, &(&1.name == req)) <
                 pos
      end)
    end)
  end

  setup do
    [
      simple_input: build_tasks(@simple_input),
      with_cycle: build_tasks(@with_cycle),
      unknown_requirements: build_tasks(@unknown_requirements),
      duplicate_requirements: build_tasks(@duplicate_requirements),
      duplicate_task: build_tasks(@duplicate_task)
    ]
  end

  test "good input", %{simple_input: simple_input} do
    right_order(TaskScheduler.compute_schedule(simple_input), simple_input)
  end

  test "with cycle", %{with_cycle: with_cycle} do
    assert_raise(Error, "the task definition contains a cycle", fn ->
      TaskScheduler.compute_schedule(with_cycle)
    end)
  end

  test "with unknown requirements", %{unknown_requirements: unknown_requirements} do
    assert_raise(Error, "some tasks are required but not defined", fn ->
      TaskScheduler.compute_schedule(unknown_requirements)
    end)
  end

  test "with duplicate requirements", %{duplicate_requirements: duplicate_requirements} do
    assert_raise(Error, "task task-4 has duplicate requirements", fn ->
      TaskScheduler.compute_schedule(duplicate_requirements)
    end)
  end

  test "with duplicate task", %{duplicate_task: duplicate_task} do
    assert_raise(Error, "task task-2 appears more than one", fn ->
      TaskScheduler.compute_schedule(duplicate_task)
    end)
  end
end
