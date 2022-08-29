defmodule TravelerWeb.AllowedHostController do
  use TravelerWeb, :controller

  alias Traveler.Hosts
  alias Traveler.Hosts.AllowedHost

  def index(conn, _params) do
    allowed_hosts = Hosts.list_allowed_hosts()
    render(conn, "index.html", allowed_hosts: allowed_hosts)
  end

  def new(conn, _params) do
    changeset = Hosts.change_allowed_host(%AllowedHost{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"allowed_host" => allowed_host_params}) do
    case Hosts.create_allowed_host(allowed_host_params) do
      {:ok, allowed_host} ->
        conn
        |> put_flash(:info, "Allowed host created successfully.")
        |> redirect(to: Routes.allowed_host_path(conn, :show, allowed_host))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    allowed_host = Hosts.get_allowed_host!(id)
    render(conn, "show.html", allowed_host: allowed_host)
  end

  def edit(conn, %{"id" => id}) do
    allowed_host = Hosts.get_allowed_host!(id)
    changeset = Hosts.change_allowed_host(allowed_host)
    render(conn, "edit.html", allowed_host: allowed_host, changeset: changeset)
  end

  def update(conn, %{"id" => id, "allowed_host" => allowed_host_params}) do
    allowed_host = Hosts.get_allowed_host!(id)

    case Hosts.update_allowed_host(allowed_host, allowed_host_params) do
      {:ok, allowed_host} ->
        conn
        |> put_flash(:info, "Allowed host updated successfully.")
        |> redirect(to: Routes.allowed_host_path(conn, :show, allowed_host))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", allowed_host: allowed_host, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    allowed_host = Hosts.get_allowed_host!(id)
    {:ok, _allowed_host} = Hosts.delete_allowed_host(allowed_host)

    conn
    |> put_flash(:info, "Allowed host deleted successfully.")
    |> redirect(to: Routes.allowed_host_path(conn, :index))
  end
end
