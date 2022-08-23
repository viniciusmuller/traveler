defmodule Traveler.Robotic do
  @moduledoc """
  Handles parsing and enforcement of robots.txt files.
  """

  require Logger

  defmodule Robots do
    @moduledoc "Represents the results of parsing a robots.txt file."
    defstruct groups: %{}, sitemaps: []
  end

  defmodule RuleGroup do
    @moduledoc false

    defstruct crawl_delay: 0,
              allows: [],
              disallows: []
  end

  defmodule RobotsToken do
    @moduledoc false

    defstruct groups: %{},
              current_agents: [],
              sitemaps: [],
              current_rule_group: %RuleGroup{},
              new_rulegroup?: false
  end

  # TODO: IDNA support
  @spec can_access?(%Robots{}, String.t(), String.t()) :: boolean()
  def can_access?(%Robots{} = robots, user_agent, url) do
    with {:ok, group} <- Map.fetch(robots.groups, user_agent) do
      check_group(group, url)
    else
      :error ->
        case Map.get(robots.groups, "*") do
          nil -> true
          group -> check_group(group, url)
        end
    end
  end

  # /foo/star/baz

  # /foo/bar
  # /foo/baz
  # /foo/*/baz
  # /foo/**/baz
  # /foo/bar/baz
  #
  #    foo
  # bar * baz
  #    baz
  #
  # a/b/c/d/e/{f}
  # %{
  #   "foo" => ["10..00"]
  #   "bar" => [100..00]
  # }

  # TODO: Use graphs to efficiently check for allowance
  defp check_group(%RuleGroup{} = _group, _url) do
    true
  end

  @spec parse(String.t() | [String.t()]) :: %Robots{}
  def parse(text) when is_binary(text) do
    text
    |> String.split("\n", trim: true)
    |> parse()
  end

  def parse(lines) do
    lines
    |> tokenize()
    |> do_parse()
    |> finish_parsing()
    |> to_robots()
  end

  defp do_parse(tokens) do
    Enum.reduce(tokens, %RobotsToken{}, &parser/2)
  end

  defp finish_parsing(%RobotsToken{} = token) do
    update_groups(token)
    |> Map.update!(:sitemaps, &Enum.reverse/1)
  end

  defp parser(token, acc) do
    case token do
      {:user_agent, ua} ->
        add_user_agent(acc, ua)

      {:allow, allow} ->
        add_allow(acc, allow)

      {:disallow, disallow} ->
        add_disallow(acc, disallow)

      {:sitemap, sm} ->
        add_sitemap(acc, sm)

      {:crawl_delay, cd} ->
        add_crawl_delay(acc, cd)

      _ ->
        Logger.warn("Unknown token while parsing robots: #{inspect(token)}")
        acc
    end
  end

  defp add_user_agent(%RobotsToken{} = token, ua) do
    if token.new_rulegroup? do
      update_groups(token)
      |> Map.put(:current_agents, [ua])
      |> Map.put(:current_rule_group, %RuleGroup{})
      |> Map.put(:new_rulegroup?, false)
    else
      add_current_agent(token, ua)
    end
  end

  defp add_allow(%RobotsToken{} = token, allow) do
    update_in(
      token.current_rule_group.allows,
      fn allows -> [allow | allows] end
    )
    |> Map.put(:new_rulegroup?, true)
  end

  defp add_disallow(%RobotsToken{} = token, disallow) do
    update_in(
      token.current_rule_group.disallows,
      fn disallows -> [disallow | disallows] end
    )
    |> Map.put(:new_rulegroup?, true)
  end

  defp add_crawl_delay(%RobotsToken{} = token, crawl_delay) do
    put_in(token.current_rule_group.crawl_delay, crawl_delay)
  end

  defp add_sitemap(%RobotsToken{} = token, sitemap) do
    update_in(token.sitemaps, fn sitemaps -> [sitemap | sitemaps] end)
  end

  defp update_groups(%RobotsToken{} = token) do
    update_in(token.groups, fn groups ->
      Enum.reduce(token.current_agents, groups, fn agent, group ->
        Map.put(group, agent, token.current_rule_group)
      end)
      |> Enum.map(fn {k, rule_group} ->
        rg = sort_rule_group_fields(rule_group)
        {k, rg}
      end)
      |> Map.new()
    end)
  end

  defp sort_rule_group_fields(%RuleGroup{} = rg) do
    rg
    |> Map.update!(:allows, &Enum.reverse/1)
    |> Map.update!(:disallows, &Enum.reverse/1)
  end

  defp add_current_agent(%RobotsToken{} = token, agent) do
    update_in(token.current_agents, fn agents -> [agent | agents] end)
  end

  defp to_robots(%RobotsToken{groups: groups, sitemaps: sitemaps}) do
    %Robots{groups: groups, sitemaps: sitemaps}
  end

  def tokenize(lines) do
    lines
    |> Stream.map(&trim_comments/1)
    |> Stream.map(&split_line/1)
    |> Stream.map(&process_line/1)
    |> Stream.filter(&(not empty?(&1)))
  end

  defp empty?(:empty), do: true
  defp empty?(_), do: false

  defp split_line(line) do
    case String.split(line, ":", trim: true) do
      [cmd | rest] -> {String.downcase(cmd), join_rest(rest)}
      _ -> {:error, nil}
    end
  end

  defp join_rest(rest) do
    rest |> Enum.join() |> String.trim()
  end

  def trim_comments(line) do
    case String.split(line, "#") do
      [content | _] -> String.trim(content)
      _ -> ""
    end
  end

  defp process_line({:error, _}), do: :empty
  defp process_line({"user-agent", ua}), do: {:user_agent, ua}

  defp process_line({"crawl-delay", cd}) do
    {int, _} = Integer.parse(cd)
    {:crawl_delay, int}
  end

  defp process_line({"allow", allow}), do: {:allow, allow}
  defp process_line({"disallow", disallow}), do: {:disallow, disallow}
  defp process_line({"sitemap", sm}), do: {:sitemap, sm}
end
