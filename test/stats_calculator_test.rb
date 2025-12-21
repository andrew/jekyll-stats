# frozen_string_literal: true

require "test_helper"

class StatsCalculatorTest < Minitest::Test
  include JekyllStats::TestHelpers

  def setup
    cleanup_fixtures
  end

  def teardown
    cleanup_fixtures
  end

  def test_empty_site_returns_zero_stats
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    assert_equal 0, stats[:total_posts]
    assert_equal 0, stats[:total_words]
    assert_equal 0, stats[:reading_minutes]
    assert_nil stats[:longest_post]
  end

  def test_counts_single_post
    create_post("2024-01-15-test.md", "Hello world this is a test post.")
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    assert_equal 1, stats[:total_posts]
    assert_equal 7, stats[:total_words]
  end

  def test_counts_multiple_posts
    create_post("2024-01-15-first.md", "First post content here.", "title" => "First")
    create_post("2024-02-20-second.md", "Second post with more words in it.", "title" => "Second", "date" => "2024-02-20")
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    assert_equal 2, stats[:total_posts]
  end

  def test_finds_longest_and_shortest_posts
    create_post("2024-01-15-short.md", "Short.", "title" => "Short Post")
    create_post("2024-02-20-long.md", "This is a much longer post with many more words in it to test the word counting.", "title" => "Long Post", "date" => "2024-02-20")
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    assert_equal "Long Post", stats[:longest_post][:title]
    assert_equal "Short Post", stats[:shortest_post][:title]
  end

  def test_calculates_reading_time
    # 200 words = 1 minute
    words = (["word"] * 400).join(" ")
    create_post("2024-01-15-long.md", words)
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    assert_equal 2, stats[:reading_minutes]
  end

  def test_counts_tags
    create_post("2024-01-15-tagged.md", "Content", "title" => "Tagged", "tags" => ["ruby", "rails"])
    create_post("2024-02-20-tagged2.md", "More content", "title" => "Tagged2", "date" => "2024-02-20", "tags" => ["ruby"])
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    ruby_tag = stats[:tags].find { |t| t[:name] == "ruby" }
    rails_tag = stats[:tags].find { |t| t[:name] == "rails" }

    assert_equal 2, ruby_tag[:count]
    assert_equal 1, rails_tag[:count]
  end

  def test_normalizes_tags_with_trailing_punctuation
    create_post("2024-01-15-tagged.md", "Content", "title" => "Tagged", "tags" => ["opensource,", "ruby"])
    create_post("2024-02-20-tagged2.md", "More content", "title" => "Tagged2", "date" => "2024-02-20", "tags" => ["opensource"])
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    opensource_tag = stats[:tags].find { |t| t[:name] == "opensource" }
    assert_equal 2, opensource_tag[:count]
    refute stats[:tags].any? { |t| t[:name] == "opensource," }
  end

  def test_counts_categories
    create_post("2024-01-15-cat.md", "Content", "title" => "Cat Post", "categories" => ["code"])
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    code_cat = stats[:categories].find { |c| c[:name] == "code" }
    assert_equal 1, code_cat[:count]
  end

  def test_posts_by_year
    create_post("2024-01-15-first.md", "Content", "title" => "2024 Post")
    create_post("2023-06-01-second.md", "Content", "title" => "2023 Post", "date" => "2023-06-01")
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    year_2024 = stats[:posts_by_year].find { |y| y[:year] == 2024 }
    year_2023 = stats[:posts_by_year].find { |y| y[:year] == 2023 }

    assert_equal 1, year_2024[:count]
    assert_equal 1, year_2023[:count]
  end

  def test_posts_by_day_of_week
    # 2024-01-15 is a Monday
    create_post("2024-01-15-monday.md", "Content", "title" => "Monday Post")
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    assert_equal 1, stats[:posts_by_day_of_week]["monday"]
    assert_equal 0, stats[:posts_by_day_of_week]["tuesday"]
  end

  def test_word_count_strips_html
    create_post("2024-01-15-html.md", "<p>Hello</p> <div>world</div>")
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    assert_equal 2, stats[:total_words]
  end

  def test_word_count_strips_markdown_links
    create_post("2024-01-15-links.md", "Check out [this link](https://example.com) here")
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    assert_equal 5, stats[:total_words]
  end

  def test_calculates_years_active
    create_post("2020-01-15-old.md", "Old post", "title" => "Old", "date" => "2020-01-15")
    create_post("2024-01-15-new.md", "New post", "title" => "New")
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    assert_in_delta 4.0, stats[:years_active], 0.1
  end

  def test_calculates_posts_per_month
    # 2 posts over 13 months (Jan 2023 to Jan 2024) = 0.154, rounds to 0.2
    create_post("2023-01-15-first.md", "First", "title" => "First", "date" => "2023-01-15")
    create_post("2024-01-15-second.md", "Second", "title" => "Second")
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    assert_in_delta 0.2, stats[:posts_per_month], 0.05
  end

  def test_generated_at_is_iso8601
    create_post("2024-01-15-test.md", "Content")
    site = fixture_site
    calculator = JekyllStats::StatsCalculator.new(site)
    stats = calculator.calculate

    assert_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, stats[:generated_at])
  end
end
