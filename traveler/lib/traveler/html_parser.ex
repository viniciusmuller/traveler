defmodule Traveler.HtmlParser do
  @moduledoc """
  Module that helps when dealing with HTML returned by sites.
  """

  defmodule ParsedPage do
    defstruct [:title, :links]
  end

  def parse_page(body, host) do
    case Floki.parse_document(body) do
      {:ok, document} ->
        title = find_title(document)

        links =
          document
          |> Floki.find("a")
          |> Floki.attribute("href")
          |> Stream.map(&find_url(&1, host))
          |> Enum.filter(&(not is_nil(&1)))

        {:ok, %ParsedPage{title: title, links: links}}

      {:error, _} ->
        {:error, :could_not_parse_document}
    end
  end

  defp find_title(document) do
    case Floki.find(document, "title") do
      [{"title", _, [title]} | _rest] -> title
      _ -> nil
    end
  end

  defp find_url(path, host) do
    with false <- String.contains?(path, "javascript:") do
      case URI.parse(path) do
        %URI{host: nil, scheme: nil} -> "https://#{host}#{path}"
        %URI{host: _, scheme: _} -> path
      end
    else
      _ -> nil
    end
  end
end
