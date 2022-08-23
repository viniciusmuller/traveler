defmodule Traveler.Workers.Crawler do
  use Oban.Worker,
    queue: :crawl,
    max_attempts: 4

  require Logger

  alias Traveler.Workers.Crawler
  alias Traveler.RoboticServer

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"url" => url} = args}) do
    %{host: host} = URI.parse(url)
    Logger.debug("now crawling #{url}")

    case RoboticServer.can_access?(url, "*") do
      {:ok, true} ->
        crawl(url, host)

      {:ok, false} ->
        {:error, :not_allowed}

      {:error, :unknown_host} ->
        RoboticServer.add_host(url)
        perform(args)
    end
  end

  defp crawl(url, host) do
    case Traveler.HttpClient.get_body(url) do
      nil ->
        {:error, :could_not_get_body}

      body ->
        with {:ok, links} <- get_urls(body, host) do
          Enum.each(links, &enqueue_crawling/1)
        end
    end
  end

  defp get_urls(body, host) do
    Traveler.HtmlParser.find_links(body, host)
  end

  defp enqueue_crawling(url) do
    Logger.debug("adding #{url} to the search queue")

    %{url: url}
    |> Crawler.new()
    |> Oban.insert()
  end
end
