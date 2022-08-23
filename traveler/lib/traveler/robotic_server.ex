defmodule Traveler.RoboticServer do
  use GenServer

  require Logger

  alias Traveler.Robotic
  alias Traveler.HttpClient

  @doc """
  Returns whether a given URL can be acessed by a given crawler.
  """
  def can_access?(host, user_agent) do
    GenServer.call(__MODULE__, {:can_access, host, user_agent})
  end

  @doc """
  Adds the given host
  """
  def add_host(url) do
    %{host: host, scheme: scheme} = URI.parse(url)

    cond do
      is_nil(host) or is_nil(scheme) ->
        {:error, :bad_host}

      true ->
        Logger.debug("fetching robots from host: #{host}")
        robots_target = "#{scheme}://#{host}/robots.txt"

        # TODO: Handle request sending errors
        robots =
          HttpClient.get_body(robots_target)
          |> Robotic.parse()

        GenServer.call(__MODULE__, {:add_host, host, robots})
    end
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
          {:error, :host_not_found}
      end

    {:reply, result, state}
  end

  @impl true
  def handle_call({:add_host, host, robots}, _from, state) do
    {:reply, robots, Map.put(state, host, robots)}
  end
end
