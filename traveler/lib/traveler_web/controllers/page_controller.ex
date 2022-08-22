defmodule TravelerWeb.PageController do
  use TravelerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
