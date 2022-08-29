defmodule Traveler.Hosts.AllowedHost do
  use Ecto.Schema
  import Ecto.Changeset

  schema "allowed_hosts" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(allowed_host, attrs) do
    allowed_host
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
