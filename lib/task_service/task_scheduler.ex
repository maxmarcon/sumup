defmodule TaskService.TaskScheduler do
  @moduledoc """
  This module exposed a `compute_schedule` function that receives a list of tasks and builds
  a graph where there is an edge `A -> B` if and only if task B requires task A.
  It then computes a topological sorting of the nodes in the graph
  """
  alias TaskService.Task
  alias TaskService.TaskScheduler.{Node, Error}

  def compute_schedule(tasks) when is_list(tasks) do
    tasks
    |> build_graph
    |> check_vailidty
    |> topological_sort
    |> map_to_jobs
  end

  defp check_vailidty(graph) do
    Enum.each(Map.values(graph), fn
      %Node{task: task} when is_nil(task) ->
        raise Error, message: "some tasks are required but not defined"

      %Node{task: %Task{name: name, requires: requires}} ->
        if length(Enum.uniq(requires)) != length(requires) do
          raise Error, message: "task #{name} has duplicate requirements"
        end
    end)

    graph
  end

  defp map_to_jobs(node_list) do
    Enum.map(node_list, fn %Node{task: task} -> task end)
  end

  defp build_graph(tasks) do
    Enum.reduce(tasks, %{}, fn %Task{name: name, requires: requires} = task, graph ->
      # add the task `name` to the graph. Note that a node for `name` might already exist
      # if `name` was a requirement for a previously encountered task

      graph =
        Map.update(
          graph,
          name,
          %Node{task: task, blocked_by: length(task.requires)},
          fn
            %Node{task: task} when not is_nil(task) ->
              raise Error, message: "task #{name} appears more than one"

            node ->
              %{node | task: task, blocked_by: length(task.requires)}
          end
        )

      # for each task rquired by `name`, add `name` to the `blocks` list in the corresponding node
      requires
      |> Enum.reduce(graph, fn requirement, graph ->
        Map.update(graph, requirement, %Node{blocks: [name]}, fn %Node{blocks: blocks} = node ->
          %{node | blocks: [name | blocks]}
        end)
      end)
    end)
  end

  defp topological_sort(graph) do
    # implementation of Kahn's algorithm

    # build the initial list of tasks that are not blocked by any other task and can run
    # immediately
    unblocked =
      graph
      |> Enum.filter(fn
        {_, %Node{blocked_by: 0}} -> true
        {_, _} -> false
      end)
      |> Enum.map(fn {name, _} -> name end)

    sort =
      Stream.unfold({graph, unblocked}, fn
        # the list of unblocked tasks is empty. We either found a topological sort or
        # a topological sort does not exist (i.e. the graph has a cycle). In either case, we are done
        {_, []} ->
          nil

        # there is at least one unblocked task. We call unblock_dependent_nodes on the tasks' node
        # the unblocked task will be the next task in the topological sort
        {graph, [unblocked_node | other_unblocked]} ->
          {graph, new_unblocked} = unblock_dependent_nodes(graph, unblocked_node)
          {Map.fetch!(graph, unblocked_node), {graph, new_unblocked ++ other_unblocked}}
      end)
      |> Enum.to_list()

    if length(sort) != Enum.count(graph) do
      raise Error, message: "the task definition contains a cycle"
    end

    sort
  end

  defp unblock_dependent_nodes(graph, unblocked_node) do
    %Node{blocks: blocked} = Map.fetch!(graph, unblocked_node)

    # we visit all the nodes that are currently blocked by `unblocked_node` and maintain
    # a list of new nodes that have become unblocked
    Enum.reduce(blocked, {graph, []}, fn node_name, {graph, new_unblocked} ->
      case Map.fetch!(graph, node_name) do
        # `unblocked_node` was the last task blocking `node_name`: it is therefore now unblocked,
        # and we add it to the list fo unblocked nodes
        %Node{blocked_by: 1} ->
          {graph, [node_name | new_unblocked]}

        # `node_name` is no longer blocked by unblocked_node. We reduce its blocked_by count by 1
        _ ->
          {Map.update!(graph, node_name, fn %Node{blocked_by: blocked_by} = node ->
             %{node | blocked_by: blocked_by - 1}
           end), new_unblocked}
      end
    end)
  end
end
