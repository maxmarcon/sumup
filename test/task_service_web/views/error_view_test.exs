defmodule TaskServiceWeb.ErrorViewTest do
  use TaskServiceWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 400.json" do
    assert render(TaskServiceWeb.ErrorView, "400.json", []) == %{error: "Bad Request"}
  end

  test "renders 400.json with message" do
    assert render(TaskServiceWeb.ErrorView, "400.json", message: "Failure") == %{error: "Failure"}
  end

  test "renders XXX.json" do
    assert render(TaskServiceWeb.ErrorView, "XXX.json", []) == %{error: "Internal Server Error"}
  end

  test "renders 400.txt" do
    assert render(TaskServiceWeb.ErrorView, "400.txt", []) == "Error: Bad Request"
  end

  test "renders 400.txt with message" do
    assert render(TaskServiceWeb.ErrorView, "400.txt", message: "Failure") == "Error: Failure"
  end

  test "renders XXX.txt" do
    assert render(TaskServiceWeb.ErrorView, "XXX.txt", []) == "Error: Internal Server Error"
  end
end
