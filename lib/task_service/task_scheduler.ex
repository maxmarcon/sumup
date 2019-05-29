defmodule TaskService.TaskScheduler do
  @moduledoc """
  """
  alias TaskService.Task
  alias TaskService.TaskScheduler.{Node, Error}
  require Logger

  def compute_schedule(tasks) when is_list(tasks) do
    tasks
    |> build_graph
    |> check_vailidty
    |> topological_sort
    |> hydrate_nodes
  end

  defp check_vailidty(graph) do
    if !is_valid?(graph) do
      raise Error, message: "some tasks are required but not defined"
    end

    graph
  end

  defp hydrate_nodes(node_list) do
    Enum.map(node_list, fn %Node{task: task} -> task end)
  end

  defp build_graph(tasks) do
    Enum.reduce(tasks, %{}, fn %Task{name: name, requires: requires} = task, graph ->
      if length(Enum.uniq(requires)) != length(requires) do
        raise Error, message: "task #{name} has duplicate requirements"
      end

      graph =
        Map.update(
          graph,
          name,
          %Node{task: task, blocked_by_cnt: length(task.requires)},
          fn
            %Node{task: task} when not is_nil(task) ->
              raise Error, message: "task #{name} appears more than one"

            node ->
              %{node | task: task, blocked_by_cnt: length(task.requires)}
          end
        )

      requires
      |> Enum.reduce(graph, fn requirement, graph ->
        Map.update(graph, requirement, %Node{blocks: [name]}, fn %Node{blocks: blocks} = node ->
          %{node | blocks: [name | blocks]}
        end)
      end)
    end)
  end

  defp is_valid?(graph) do
    Enum.all?(Map.values(graph), fn %Node{task: task} -> !is_nil(task) end)
  end

  defp topological_sort(graph) do
    unblocked =
      graph
      |> Enum.filter(fn
        {_, %Node{blocked_by_cnt: 0}} -> true
        {_, _} -> false
      end)
      |> Enum.map(fn {name, _} -> name end)

    sort =
      Stream.unfold({graph, unblocked}, fn
        {_, []} ->
          nil

        {graph, [unblocked_node | other_unblocked]} ->
          {graph, new_unblocked} = unblock_dependent_nodes(graph, unblocked_node)
          {Map.fetch!(graph, unblocked_node), {graph, new_unblocked ++ other_unblocked}}
      end)
      |> Enum.to_list()

    if length(sort) != Enum.count(graph) do
      raise Error, message: "the task list contains a cycle"
    end

    sort
  end

  defp unblock_dependent_nodes(graph, unblocked_node) do
    %Node{blocks: blocked} = Map.fetch!(graph, unblocked_node)

    Enum.reduce(blocked, {graph, []}, fn node_name, {graph, new_unblocked} ->
      case Map.fetch!(graph, node_name) do
        %Node{blocked_by_cnt: 1} ->
          {graph, [node_name | new_unblocked]}

        _ ->
          {Map.update!(graph, node_name, fn %Node{blocked_by_cnt: blocked_by_cnt} = node ->
             %{node | blocked_by_cnt: blocked_by_cnt - 1}
           end), new_unblocked}
      end
    end)
  end
end
