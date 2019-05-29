defmodule TaskServiceWeb.Router do
  use TaskServiceWeb, :router

  pipeline :api do
    plug :accepts, ["txt", "json"]
  end

  scope "/api", TaskServiceWeb do
    pipe_through :api

    post "/schedule", TaskController, :schedule
  end
end
