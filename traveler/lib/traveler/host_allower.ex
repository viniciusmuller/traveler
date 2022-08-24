defmodule Traveler.HostAllower do
  use GenServer

  @impl true
  def init(:ok) do
    {:ok, MapSet.new()}
  end

  @doc """
  Starts the server.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def allow_host(host) when is_binary(host) do
    GenServer.call(__MODULE__, {:allow_host, host})
  end

  def host_allowed?(host) when is_binary(host) do
    GenServer.call(__MODULE__, {:host_allowed?, host})
  end

  @impl true
  def handle_call({:host_allowed?, _host}, _from, cache) do
    # case MapSet.member?(cache, host) do
    #   true -> true
    #   false -> false
    # end
    {:reply, true, cache}
  end

  @impl true
  def handle_call({:allow_host, host}, _from, cache) do
    {:reply, :ok, MapSet.put(cache, host)}
  end
end
