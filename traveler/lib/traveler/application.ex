defmodule Traveler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Traveler.Repo,
      # Server used for checking permissions when crawling URLs
      {Traveler.RoboticServer, name: Traveler.RoboticServer},
      # Server that handles allowed hosts
      {Traveler.HostAllower, name: Traveler.HostAllower},
      # Neo4j driver
      {Bolt.Sips, Application.get_env(:bolt_sips, Bolt)},
      # Oban
      {Oban, Application.fetch_env!(:traveler, Oban)},
      # HTTP Client
      {Finch, name: MyFinch},
      # Start the Telemetry supervisor
      TravelerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Traveler.PubSub},
      # Start the Endpoint (http/https)
      TravelerWeb.Endpoint
      # Start a worker by calling: Traveler.Worker.start_link(arg)
      # {Traveler.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Traveler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TravelerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
