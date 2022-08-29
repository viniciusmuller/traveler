defmodule Traveler.Repo.Migrations.CreateAllowedHosts do
  use Ecto.Migration

  def change do
    create table(:allowed_hosts) do
      add :name, :string

      timestamps()
    end
  end
end
