defmodule JobService.JobSchedulerTest do
  use JobService.DataCase

  alias JobService.JobScheduler

  describe "jobs" do
    alias JobService.JobScheduler.Job

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def job_fixture(attrs \\ %{}) do
      {:ok, job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> JobScheduler.create_job()

      job
    end

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert JobScheduler.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert JobScheduler.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      assert {:ok, %Job{} = job} = JobScheduler.create_job(@valid_attrs)
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = JobScheduler.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      assert {:ok, %Job{} = job} = JobScheduler.update_job(job, @update_attrs)
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = JobScheduler.update_job(job, @invalid_attrs)
      assert job == JobScheduler.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = JobScheduler.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> JobScheduler.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = JobScheduler.change_job(job)
    end
  end
end
