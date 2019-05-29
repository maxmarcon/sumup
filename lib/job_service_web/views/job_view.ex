defmodule JobServiceWeb.JobView do
  use JobServiceWeb, :view
  alias JobServiceWeb.JobView
  alias JobService.Job

  def render("schedule.json", %{jobs: jobs}) do
    render_many(jobs, JobView, "job.json")
  end

  require Logger

  def render("schedule.txt", %{jobs: jobs}) do
    "#!/usr/bin/env bash\n\n" <>
      Enum.join(render_many(jobs, JobView, "job.txt"), "\n")
  end

  def render("job.json", %{job: %Job{name: name, command: command}}) do
    %{name: name, command: command}
  end

  def render("job.txt", %{job: job}) do
    String.Chars.to_string(job)
  end
end
