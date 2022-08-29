defmodule Traveler.HostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Traveler.Hosts` context.
  """

  @doc """
  Generate a allowed_host.
  """
  def allowed_host_fixture(attrs \\ %{}) do
    {:ok, allowed_host} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Traveler.Hosts.create_allowed_host()

    allowed_host
  end
end
