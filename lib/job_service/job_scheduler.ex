defmodule JobService.JobScheduler do
  @moduledoc """
  """
  alias JobService.{Job, Node}
  require Logger

  def compute_schedule(jobs) when is_list(jobs) do
    jobs
    |> build_graph
    |> check_vailidty
    |> topological_sort
    |> hydrate_nodes
  end

  defp check_vailidty(graph) do
    if !is_valid?(graph) do
      raise "some nodes in the graph have no jobs!"
    end

    graph
  end

  defp hydrate_nodes(node_list) do
    Enum.map(node_list, fn %Node{job: job} -> job end)
  end

  defp build_graph(jobs) do
    Enum.reduce(jobs, %{}, fn %Job{name: name, requires: requires} = job, graph ->
      graph =
        Map.update(
          graph,
          name,
          %Node{job: job, blocked_by_cnt: length(job.requires)},
          fn node -> %{node | job: job, blocked_by_cnt: length(job.requires)} end
        )

      Enum.reduce(requires, graph, fn requirement, graph ->
        Map.update(graph, requirement, %Node{blocks: [name]}, fn %Node{blocks: blocks} = node ->
          %{node | blocks: [name | blocks]}
        end)
      end)
    end)
  end

  defp is_valid?(graph) do
    Enum.all?(Map.values(graph), fn %Node{job: job} -> !is_nil(job) end)
  end

  defp topological_sort(graph) do
    unblocked =
      graph
      |> Enum.filter(fn
        {name, %Node{blocked_by_cnt: 0}} -> true
        {name, _} -> false
      end)
      |> Enum.map(fn {name, _} -> name end)

    Stream.unfold({graph, unblocked}, fn
      {_, []} ->
        nil

      {graph, [unblocked_node | other_unblocked]} ->
        {graph, new_unblocked} = unblock_dependent_nodes(graph, unblocked_node)
        {Map.fetch!(graph, unblocked_node), {graph, new_unblocked ++ other_unblocked}}
    end)
    |> Enum.to_list()
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
