defmodule Traveler.HtmlParser do
  def find_links(body, host) do
    case Floki.parse_document(body) do
      {:ok, document} ->
        result =
          document
          |> Floki.find("a")
          |> Floki.attribute("href")
          |> Stream.map(&find_url(&1, host))
          |> Enum.filter(&(not is_nil(&1)))

        {:ok, result}

      {:error, _} ->
        {:ok, :could_not_parse_document}
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
