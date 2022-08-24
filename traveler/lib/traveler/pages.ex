defmodule Traveler.Pages do
  alias Traveler.Schemas.Page
  alias Bolt.Sips, as: Neo

  @add """
  CREATE (n:Page {body: $body, title: $title, url: $url})
  """
  def add_page(url, body, nil) do
    conn = Neo.conn()
    title = "my-page"
    Neo.query(conn, @add, %{url: url, body: body, title: title})
  end

  @add_relationship """
  MATCH
    (a:Page),
    (b:Page)
  WHERE a.url = $url AND b.url = $referrer_url
  CREATE (b)-[r:LINKS]->(a)
  """
  def add_page(url, body, referrer_url) do
    add_page(url, body, nil)
    conn = Neo.conn()
    Neo.query(conn, @add_relationship, %{url: url, referrer_url: referrer_url})
  end

  @get """
  MATCH (p:Page)
  WHERE p.url = $url
  RETURN p
  """
  def get_page(url) do
    conn = Neo.conn()

    case Neo.query(conn, @get, %{url: url}) do
      {:ok, results} ->
        result = Enum.map(results, &result_to_page/1)
        case result do
          [result] -> {:ok, result}
          [] -> :error
        end

      err ->
        err
    end
  end

  defp result_to_page(result) do
    # "p" is the binding given in the query
    Map.get(result, "p")
    |> Map.fetch!(:properties)
    |> to_page_struct()
  end

  # For now let's just do it that way, and when we need we find a better way of
  # converting this.
  defp to_page_struct(properties) do
    %Page{
      url: properties["url"],
      title: properties["title"],
      body: properties["body"]
    }
  end
end
