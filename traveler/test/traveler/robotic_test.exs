defmodule Traveler.RoboticTest do
  use TravelerWeb.ConnCase

  alias Traveler.Robotic

  test "parse/1 ignores comments" do
    robots = """
      # robots.txt file for YouTube
      # Created in the distant future (the year 2000) after
      # the robotic uprising of the mid 90's which wiped out all humans.

      User-agent: mysterious
      Disallow: *
    """

    expected = %Traveler.Robotic.Robots{
      groups: %{
        "mysterious" => %Traveler.Robotic.RuleGroup{
          disallows: ["*"]
        }
      }
    }

    assert Robotic.parse(robots) == expected
  end

  test "parse/1 parses crawl-delay" do
    robots = """
      User-agent: *
      Disallow:
      crawl-delay: 30
    """

    expected = %Traveler.Robotic.Robots{
      groups: %{
        "*" => %Traveler.Robotic.RuleGroup{
          disallows: [""],
          crawl_delay: 30
        }
      }
    }

    assert Robotic.parse(robots) == expected
  end

  test "parse/1 parses allowances" do
    robots = """
      User-agent: *
      Allow: /foo
      Allow: /bar
    """

    expected = %Traveler.Robotic.Robots{
      groups: %{
        "*" => %Traveler.Robotic.RuleGroup{
          allows: ["/foo", "/bar"]
        }
      }
    }

    assert Robotic.parse(robots) == expected
  end

  test "parse/1 parses disallowances" do
    robots = """
      User-agent: *
      Disallow: /foo
      Disallow: /bar
    """

    expected = %Traveler.Robotic.Robots{
      groups: %{
        "*" => %Traveler.Robotic.RuleGroup{
          disallows: ["/foo", "/bar"]
        }
      }
    }

    assert Robotic.parse(robots) == expected
  end

  test "parse/1 parses sitemaps" do
    robots = """
      User-agent: *
      Disallow: /foo
      Disallow: /bar

      Sitemap: /foo/bar.xml
      Sitemap: /foo/baz.xml
    """

    expected = %Traveler.Robotic.Robots{
      groups: %{
        "*" => %Traveler.Robotic.RuleGroup{
          disallows: ["/foo", "/bar"]
        }
      },
      sitemaps: ["/foo/bar.xml", "/foo/baz.xml"]
    }

    assert Robotic.parse(robots) == expected
  end

  test "parse/1 parses different user agents" do
    robots = """
      User-agent: foo
      Disallow:

      User-agent: bar
      Disallow: /test
      Disallow: /secret
    """

    expected = %Traveler.Robotic.Robots{
      groups: %{
        "foo" => %Traveler.Robotic.RuleGroup{
          disallows: [""]
        },
        "bar" => %Traveler.Robotic.RuleGroup{
          disallows: ["/test", "/secret"]
        }
      }
    }

    assert Robotic.parse(robots) == expected
  end
end
