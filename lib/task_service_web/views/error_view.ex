defmodule TaskServiceWeb.ErrorView do
  use TaskServiceWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".

  def template_not_found(<<_status::binary-size(3), ".json">>, %{message: message}) do
    %{
      error: message
    }
  end

  def template_not_found(<<_status::binary-size(3), ".json">> = template, _assigns) do
    %{
      error: Phoenix.Controller.status_message_from_template(template)
    }
  end

  def template_not_found(<<_status::binary-size(3), ".txt">>, %{message: message}) do
    "Error: #{message}"
  end

  def template_not_found(<<_status::binary-size(3), ".txt">> = template, _assigns) do
    "Error: #{Phoenix.Controller.status_message_from_template(template)}"
  end
end
