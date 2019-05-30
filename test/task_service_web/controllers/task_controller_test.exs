defmodule TaskServiceWeb.JobControllerTest do
  use TaskServiceWeb.ConnCase

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

  @missing_name ~S"""
    {
    "tasks": [{
      "name": "",
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

  @invalid_keys ~S"""
    {
    "tasks": [{
      "nick_name": "task-1",
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

  @no_task_list ~S"""
  {
    "tasks": "list of tasks..."
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

  setup %{conn: conn} do
    [conn: put_req_header(conn, "content-type", "application/json")]
  end

  describe "with json response" do
    setup %{conn: conn} do
      [conn: put_req_header(conn, "accept", "application/json")]
    end

    test "valid input works", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :schedule), @simple_input)

      list = json_response(conn, 200)

      assert Enum.sort(Enum.map(list, & &1["name"])) == ["task-1", "task-2", "task-3", "task-4"]
    end

    test "when TaskScheduler raises, returns a 400", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :schedule), @with_cycle)

      error = json_response(conn, 400)["error"]

      assert error == "the task definition contains a cycle"
    end

    test "invalid input returns a 400", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :schedule), @invalid_keys)

      error = json_response(conn, 400)["error"]

      assert error == "tasks may only contains the 'command', 'name', and 'requires' keys"
    end

    test "different invalid input returns a 400", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :schedule), @missing_name)

      error = json_response(conn, 400)["error"]

      assert error == "some tasks don't have a name"
    end

    test "input without a list returns a 400", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :schedule), @no_task_list)

      error = json_response(conn, 400)["error"]

      assert error == "tasks must be a list"
    end
  end

  describe "with text response" do
    setup %{conn: conn} do
      [conn: put_req_header(conn, "accept", "text/plain")]
    end

    test "valid input works", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :schedule), @simple_input)

      response = text_response(conn, 200)

      assert response ==
               String.trim_trailing(~S"""
               #!/usr/bin/env bash

               touch /tmp/file1
               echo 'Hello World!' > /tmp/file1
               cat /tmp/file1
               rm /tmp/file1
               """)
    end

    test "when TaskScheduler raises, returns a 400", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :schedule), @with_cycle)

      error = text_response(conn, 400)

      assert error == "Error: the task definition contains a cycle"
    end

    test "invalid input returns a 400", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :schedule), @invalid_keys)

      error = text_response(conn, 400)

      assert error == "Error: tasks may only contains the 'command', 'name', and 'requires' keys"
    end

    test "different invalid input returns a 400", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :schedule), @missing_name)

      error = text_response(conn, 400)

      assert error == "Error: some tasks don't have a name"
    end

    test "input without a list returns a 400", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :schedule), @no_task_list)

      error = text_response(conn, 400)

      assert error == "Error: tasks must be a list"
    end
  end
end
