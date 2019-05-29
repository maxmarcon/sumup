defmodule TaskService.TaskSchedulerTest do
  use TaskService.DataCase

  alias TaskService.TaskScheduler

  describe "jobs" do
    alias TaskService.TaskScheduler.Job

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def job_fixture(attrs \\ %{}) do
      {:ok, job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TaskScheduler.create_job()

      job
    end

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert TaskScheduler.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert TaskScheduler.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      assert {:ok, %Job{} = job} = TaskScheduler.create_job(@valid_attrs)
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TaskScheduler.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      assert {:ok, %Job{} = job} = TaskScheduler.update_job(job, @update_attrs)
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = TaskScheduler.update_job(job, @invalid_attrs)
      assert job == TaskScheduler.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = TaskScheduler.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> TaskScheduler.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = TaskScheduler.change_job(job)
    end
  end
end
