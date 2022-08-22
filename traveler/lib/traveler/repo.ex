defmodule Traveler.Repo do
  use Ecto.Repo,
    otp_app: :traveler,
    adapter: Ecto.Adapters.Postgres
end
