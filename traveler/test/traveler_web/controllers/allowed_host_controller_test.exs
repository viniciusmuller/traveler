defmodule TravelerWeb.AllowedHostControllerTest do
  use TravelerWeb.ConnCase

  import Traveler.HostsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all allowed_hosts", %{conn: conn} do
      conn = get(conn, Routes.allowed_host_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Allowed hosts"
    end
  end

  describe "new allowed_host" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.allowed_host_path(conn, :new))
      assert html_response(conn, 200) =~ "New Allowed host"
    end
  end

  describe "create allowed_host" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.allowed_host_path(conn, :create), allowed_host: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.allowed_host_path(conn, :show, id)

      conn = get(conn, Routes.allowed_host_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Allowed host"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.allowed_host_path(conn, :create), allowed_host: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Allowed host"
    end
  end

  describe "edit allowed_host" do
    setup [:create_allowed_host]

    test "renders form for editing chosen allowed_host", %{conn: conn, allowed_host: allowed_host} do
      conn = get(conn, Routes.allowed_host_path(conn, :edit, allowed_host))
      assert html_response(conn, 200) =~ "Edit Allowed host"
    end
  end

  describe "update allowed_host" do
    setup [:create_allowed_host]

    test "redirects when data is valid", %{conn: conn, allowed_host: allowed_host} do
      conn = put(conn, Routes.allowed_host_path(conn, :update, allowed_host), allowed_host: @update_attrs)
      assert redirected_to(conn) == Routes.allowed_host_path(conn, :show, allowed_host)

      conn = get(conn, Routes.allowed_host_path(conn, :show, allowed_host))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, allowed_host: allowed_host} do
      conn = put(conn, Routes.allowed_host_path(conn, :update, allowed_host), allowed_host: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Allowed host"
    end
  end

  describe "delete allowed_host" do
    setup [:create_allowed_host]

    test "deletes chosen allowed_host", %{conn: conn, allowed_host: allowed_host} do
      conn = delete(conn, Routes.allowed_host_path(conn, :delete, allowed_host))
      assert redirected_to(conn) == Routes.allowed_host_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.allowed_host_path(conn, :show, allowed_host))
      end
    end
  end

  defp create_allowed_host(_) do
    allowed_host = allowed_host_fixture()
    %{allowed_host: allowed_host}
  end
end
