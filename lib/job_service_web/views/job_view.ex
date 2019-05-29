defmodule JobServiceWeb.JobView do
  use JobServiceWeb, :view
  alias JobServiceWeb.JobView
  alias JobService.Job

  def render("schedule.json", %{jobs: jobs}) do
    render_many(jobs, JobView, "job.json")
  end

  def render("job.json", %{job: %Job{name: name, command: command}}) do
    %{name: name, command: command}
  end
end
