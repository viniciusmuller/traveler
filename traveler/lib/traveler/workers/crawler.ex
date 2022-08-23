defmodule Traveler.Workers.Crawler do
  use Oban.Worker,
    queue: :crawl,
    max_attempts: 4

  require Logger

  alias Traveler.Workers.Crawler

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"url" => url}}) do
    %{host: host} = URI.parse(url)
    Logger.debug("now crawling #{url}")

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
