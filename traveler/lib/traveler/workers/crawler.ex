defmodule Traveler.Workers.Crawler do
  use Oban.Worker,
    queue: :crawl,
    max_attempts: 4

  require Logger

  alias Traveler.Workers.Crawler

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"url" => url}}) do
    %{host: host} = URI.parse(url)

    Logger.info("crawling #{url}")
    case Traveler.HttpClient.get_body(url) do
      nil ->
        nil

      body ->
        body |> get_urls(host) |> Enum.map(&enqueue_crawling/1)
    end

    :ok
  end

  defp get_urls(host, body) do
    Traveler.HtmlParser.find_links(body, host)
  end

  defp enqueue_crawling(url) do
    %{url: url}
    |> Crawler.new()
    |> Oban.insert()
  end
end
