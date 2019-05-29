defmodule TaskServiceWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use TaskServiceWeb, :controller

  def call(conn, :ok) do
    send_resp(conn, :no_content, "")
  end

  def call(conn, {:error, status}) when is_atom(status) or is_integer(status) do
    render_error(conn, code_from_status(status))
  end

  def call(conn, {:error, status, message}) when is_atom(status) or is_integer(status) do
    render_error(conn, code_from_status(status), message)
  end

  defp code_from_status(status) when is_atom(status) or is_integer(status) do
    try do
      Plug.Conn.Status.code(status)
    rescue
      FunctionClauseError -> 500
    end
  end

  defp render_error(conn, code, message \\ nil) do
    assigns =
      if is_nil(message) do
        %{}
      else
        %{message: message}
      end

    conn
    |> put_status(code)
    |> put_view(TaskServiceWeb.ErrorView)
    |> render(String.to_atom(Integer.to_string(code)), assigns)
  end
end
