defmodule Traveler.PagesQueue do
  use Agent

  @doc """
  Starts the server.
  """
  def start_link(_inital_value) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get_page do
    Agent.get_and_update(__MODULE__, fn
      [] ->
        {{:error, :empty}, []}

      [head | rest] ->
        {{:ok, head}, rest}
    end)
  end

  def add_page(url) do
    Agent.update(__MODULE__, fn state ->
      [url | state]
    end)
  end
end
