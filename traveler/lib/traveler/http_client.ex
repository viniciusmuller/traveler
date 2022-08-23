defmodule Traveler.HttpClient do
  @moduledoc """
  Module used for interfacing with the world-wide-web
  """

  @spec get_body(String.t()) :: String.t() | nil
  def get_body(url) do
    case request(url) do
      {:ok, response} -> response.body
      {:error, _} -> nil
    end
  end

  defp request(url) do
    Finch.build(:get, url)
    |> Finch.request(MyFinch)
  end
end
