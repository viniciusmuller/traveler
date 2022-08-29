defmodule Traveler.Hosts do
  @moduledoc """
  The Hosts context.
  """

  import Ecto.Query, warn: false
  alias Traveler.Repo

  alias Traveler.Hosts.AllowedHost

  @doc """
  Returns the list of allowed_hosts.

  ## Examples

      iex> list_allowed_hosts()
      [%AllowedHost{}, ...]

  """
  def list_allowed_hosts do
    Repo.all(AllowedHost)
  end

  @doc """
  Gets a single allowed_host.

  Raises `Ecto.NoResultsError` if the Allowed host does not exist.

  ## Examples

      iex> get_allowed_host!(123)
      %AllowedHost{}

      iex> get_allowed_host!(456)
      ** (Ecto.NoResultsError)

  """
  def get_allowed_host!(id), do: Repo.get!(AllowedHost, id)

  def fetch_allowed_host(host) do
    query = from h in AllowedHost, where: h.name == ^host

    case Repo.one(query) do
      nil -> :error
      host -> {:ok, host}
    end
  end

  @doc """
  Creates a allowed_host.

  ## Examples

      iex> create_allowed_host(%{field: value})
      {:ok, %AllowedHost{}}

      iex> create_allowed_host(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_allowed_host(attrs \\ %{}) do
    %AllowedHost{}
    |> AllowedHost.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a allowed_host.

  ## Examples

      iex> update_allowed_host(allowed_host, %{field: new_value})
      {:ok, %AllowedHost{}}

      iex> update_allowed_host(allowed_host, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_allowed_host(%AllowedHost{} = allowed_host, attrs) do
    allowed_host
    |> AllowedHost.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a allowed_host.

  ## Examples

      iex> delete_allowed_host(allowed_host)
      {:ok, %AllowedHost{}}

      iex> delete_allowed_host(allowed_host)
      {:error, %Ecto.Changeset{}}

  """
  def delete_allowed_host(%AllowedHost{} = allowed_host) do
    Repo.delete(allowed_host)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking allowed_host changes.

  ## Examples

      iex> change_allowed_host(allowed_host)
      %Ecto.Changeset{data: %AllowedHost{}}

  """
  def change_allowed_host(%AllowedHost{} = allowed_host, attrs \\ %{}) do
    AllowedHost.changeset(allowed_host, attrs)
  end
end
