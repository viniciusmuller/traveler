defmodule Traveler.CrawlerManager do
  @ten_seconds 5 * 1000
  @total_workers 10

  use GenServer

  require Logger

  alias Traveler.Workers.Crawler

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_state) do
    # Work to be performed in the start
    schedule_work()
    {:ok, nil}
  end

  @impl true
  def handle_info(:work, state) do
    Logger.debug("starting #{@total_workers} crawler instances")

    for _ <- 1..@total_workers,
        do: Task.Supervisor.async(Traveler.TaskSupervisor, &Crawler.crawl/0)

    schedule_work()
    {:noreply, state}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end

  defp schedule_work do
    # After 5 seconds(5 * 1000 in milliseconds) the desired task will take place.
    Process.send_after(self(), :work, 5 * 1000)
  end
end
