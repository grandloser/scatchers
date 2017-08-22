defmodule Scatchers.PageController do
  use Scatchers.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
