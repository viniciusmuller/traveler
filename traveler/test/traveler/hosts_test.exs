defmodule Traveler.HostsTest do
  use Traveler.DataCase

  alias Traveler.Hosts

  describe "allowed_hosts" do
    alias Traveler.Hosts.AllowedHost

    import Traveler.HostsFixtures

    @invalid_attrs %{name: nil}

    test "list_allowed_hosts/0 returns all allowed_hosts" do
      allowed_host = allowed_host_fixture()
      assert Hosts.list_allowed_hosts() == [allowed_host]
    end

    test "get_allowed_host!/1 returns the allowed_host with given id" do
      allowed_host = allowed_host_fixture()
      assert Hosts.get_allowed_host!(allowed_host.id) == allowed_host
    end

    test "create_allowed_host/1 with valid data creates a allowed_host" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %AllowedHost{} = allowed_host} = Hosts.create_allowed_host(valid_attrs)
      assert allowed_host.name == "some name"
    end

    test "create_allowed_host/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hosts.create_allowed_host(@invalid_attrs)
    end

    test "update_allowed_host/2 with valid data updates the allowed_host" do
      allowed_host = allowed_host_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %AllowedHost{} = allowed_host} = Hosts.update_allowed_host(allowed_host, update_attrs)
      assert allowed_host.name == "some updated name"
    end

    test "update_allowed_host/2 with invalid data returns error changeset" do
      allowed_host = allowed_host_fixture()
      assert {:error, %Ecto.Changeset{}} = Hosts.update_allowed_host(allowed_host, @invalid_attrs)
      assert allowed_host == Hosts.get_allowed_host!(allowed_host.id)
    end

    test "delete_allowed_host/1 deletes the allowed_host" do
      allowed_host = allowed_host_fixture()
      assert {:ok, %AllowedHost{}} = Hosts.delete_allowed_host(allowed_host)
      assert_raise Ecto.NoResultsError, fn -> Hosts.get_allowed_host!(allowed_host.id) end
    end

    test "change_allowed_host/1 returns a allowed_host changeset" do
      allowed_host = allowed_host_fixture()
      assert %Ecto.Changeset{} = Hosts.change_allowed_host(allowed_host)
    end
  end
end
