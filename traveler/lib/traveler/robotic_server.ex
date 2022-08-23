defmodule Traveler.RoboticServer do
  use GenServer

  require Logger

  alias Traveler.Robotic
  alias Traveler.HttpClient

  def can_access?(host, user_agent) do
    GenServer.call(__MODULE__, {:can_access, host, user_agent})
  end

  def add_host(host) do
    GenServer.call(__MODULE__, {:add_host, host})
  end

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @doc """
  Starts the server.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def handle_call({:can_access, url, user_agent}, _from, state) do
    %{host: host} = URI.parse(url)

    result =
      case Map.fetch(state, host) do
        {:ok, robots} ->
          {:ok, Robotic.can_access?(robots, user_agent, url)}

        :error ->
          {:error, :unknown_host}
      end

    {:reply, result, state}
  end

  @impl true
  def handle_call({:add_host, host}, _from, state) do
    %{host: host, scheme: scheme} = URI.parse(host)

    if is_nil(host) or is_nil(scheme) do
      {:reply, {:error, :bad_host}, state}
    else
      robots_target = "#{scheme}://#{host}/robots.txt"
      # TODO: Maybe turn this into a cast for performance?
      robots =
        HttpClient.get_body(robots_target)
        |> Robotic.parse()

      Logger.debug("fetching robots from host: #{host}")

      {:reply, robots, Map.put(state, host, robots)}
    end
  end
end
