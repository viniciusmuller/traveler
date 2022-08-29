defmodule Traveler.Workers.Crawler do
  require Logger

  alias Traveler.RoboticServer
  alias Traveler.Pages
  alias Traveler.Hosts
  alias Traveler.PagesQueue
  alias Traveler.Schemas.Page
  alias Traveler.HtmlParser

  def crawl() do
    url = PagesQueue.get_page()
    crawl(url)
  end

  def crawl(url) do
    case url do
      {:ok, url} ->
        %{host: host} = URI.parse(url)

        with {:ok, _} <- Hosts.fetch_allowed_host(host),
             {:ok, true} <- RoboticServer.can_access?(url, "*") do
          Logger.debug("#{inspect(self())} now crawling #{url}")
          crawl(url, host)
        else
          {:ok, false} ->
            {:error, :not_allowed}

          {:error, :host_not_found} ->
            # TODO: This will recurse indefinitely if the request fails and does not
            # add the host to the server's state.
            # TODO: Handle this
            RoboticServer.add_host(url)
            IO.inspect(url)

          :error ->
            {:error, :disallowed_host}
        end

      {:error, :empty} ->
        Logger.debug("#{inspect(self())} no urls to crawl")
        nil
    end
  end

  defp crawl(url, host) do
    case Traveler.HttpClient.get_body(url) do
      nil ->
        {:error, :could_not_get_body}

      body ->
        with {:ok, %HtmlParser.ParsedPage{links: links, title: title}} <-
               HtmlParser.parse_page(body, host) do
          # TODO: Struct for referrer? currently it's a {url, title} tuple
          Enum.each(links, &enqueue_crawling(&1, {url, title}))
        end
    end
  end

  defp enqueue_crawling(url, {referrer_url, title} = referrer) do
    # only add page to crawling if it does not exist already
    with :error <- Pages.fetch_page(url) do
      Logger.debug("url: #{url}, referrer: #{inspect referrer}")
      Logger.debug("adding #{url} to the search queue")

      # If the page already exists in the db, don't index it again
      case Pages.fetch_page(url) do
        {:ok, %Page{}} ->
          nil

        # Otherwise index it
        :error ->
          Pages.add_page(url, "body", title)
          PagesQueue.add_page(url)
      end
    end

    # TODO: Linking seems to be working for some sites
    {:ok, _} = Pages.relate_pages(url, referrer_url)
  end
end
