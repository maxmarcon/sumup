defmodule JobServiceWeb.Router do
  use JobServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", JobServiceWeb do
    pipe_through :api

    post "/schedule", JobController, :schedule
  end
end
