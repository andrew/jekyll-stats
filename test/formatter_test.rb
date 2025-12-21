# frozen_string_literal: true

require "test_helper"

class FormatterTest < Minitest::Test
  def test_empty_stats_message
    stats = {
      total_posts: 0,
      total_words: 0,
      reading_minutes: 0,
      average_words: 0,
      longest_post: nil,
      shortest_post: nil,
      first_post: nil,
      last_post: nil,
      years_active: 0,
      posts_per_month: 0,
      posts_by_year: [],
      posts_by_month: [],
      posts_by_day_of_week: {},
      tags: [],
      categories: [],
      drafts_count: 0
    }

    formatter = JekyllStats::Formatter.new(stats)
    assert_equal "No posts found.", formatter.to_terminal
  end

  def test_formats_basic_stats
    stats = sample_stats
    formatter = JekyllStats::Formatter.new(stats)
    output = formatter.to_terminal

    assert_includes output, "Site Statistics"
    assert_includes output, "Posts: 10"
    assert_includes output, "5,000 words"
  end

  def test_formats_reading_time_minutes
    stats = sample_stats.merge(reading_minutes: 45)
    formatter = JekyllStats::Formatter.new(stats)
    output = formatter.to_terminal

    assert_includes output, "~45m read time"
  end

  def test_formats_reading_time_hours
    stats = sample_stats.merge(reading_minutes: 125)
    formatter = JekyllStats::Formatter.new(stats)
    output = formatter.to_terminal

    assert_includes output, "~2h 5m read time"
  end

  def test_formats_posts_by_year
    stats = sample_stats
    formatter = JekyllStats::Formatter.new(stats)
    output = formatter.to_terminal

    assert_includes output, "Posts by Year:"
    assert_includes output, "2024:"
  end

  def test_formats_tags
    stats = sample_stats
    formatter = JekyllStats::Formatter.new(stats)
    output = formatter.to_terminal

    assert_includes output, "Top 2 Tags:"
    assert_includes output, "ruby (5)"
    assert_includes output, "rails (3)"
  end

  def test_formats_categories
    stats = sample_stats
    formatter = JekyllStats::Formatter.new(stats)
    output = formatter.to_terminal

    assert_includes output, "Categories:"
    assert_includes output, "code (8)"
  end

  def test_shows_drafts_count_when_present
    stats = sample_stats.merge(drafts_count: 3)
    formatter = JekyllStats::Formatter.new(stats)
    output = formatter.to_terminal

    assert_includes output, "Drafts: 3"
  end

  def test_hides_drafts_when_zero
    stats = sample_stats.merge(drafts_count: 0)
    formatter = JekyllStats::Formatter.new(stats)
    output = formatter.to_terminal

    refute_includes output, "Drafts:"
  end

  def test_truncates_long_titles
    stats = sample_stats.merge(
      longest_post: { title: "This is an extremely long post title that should be truncated", url: "/test", words: 1000 }
    )
    formatter = JekyllStats::Formatter.new(stats)
    output = formatter.to_terminal

    assert_includes output, "This is an extremely long post..."
  end

  def test_formats_large_numbers_with_commas
    stats = sample_stats.merge(total_words: 123456)
    formatter = JekyllStats::Formatter.new(stats)
    output = formatter.to_terminal

    assert_includes output, "123,456 words"
  end

  def sample_stats
    {
      total_posts: 10,
      total_words: 5000,
      reading_minutes: 25,
      average_words: 500,
      longest_post: { title: "Longest Post", url: "/longest", words: 1000 },
      shortest_post: { title: "Shortest Post", url: "/shortest", words: 100 },
      first_post: { title: "First Post", url: "/first", date: "2023-01-01" },
      last_post: { title: "Last Post", url: "/last", date: "2024-12-01" },
      years_active: 1.9,
      posts_per_month: 0.5,
      posts_by_year: [{ year: 2024, count: 6 }, { year: 2023, count: 4 }],
      posts_by_month: [{ month: "2024-12", count: 2 }],
      posts_by_day_of_week: { "monday" => 3, "tuesday" => 2 },
      tags: [{ name: "ruby", count: 5 }, { name: "rails", count: 3 }],
      categories: [{ name: "code", count: 8 }],
      drafts_count: 0
    }
  end
end
