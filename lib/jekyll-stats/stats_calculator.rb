# frozen_string_literal: true

module JekyllStats
  class StatsCalculator
    WORDS_PER_MINUTE = 200

    attr_reader :site, :include_drafts, :filter_tags

    def initialize(site, include_drafts: false, filter_tags: nil)
      @site = site
      @include_drafts = include_drafts
      @filter_tags = normalize_filter_tags(filter_tags)
    end

    def calculate
      posts = collect_posts
      return empty_stats if posts.empty?

      word_counts = posts.map { |p| [p, word_count(p)] }
      sorted_by_words = word_counts.sort_by { |_, count| -count }
      sorted_by_date = posts.sort_by { |p| p.date }

      total_words = word_counts.sum { |_, count| count }
      dates = sorted_by_date.map(&:date)

      {
        generated_at: Time.now.utc.iso8601,
        total_posts: posts.size,
        total_words: total_words,
        reading_minutes: (total_words / WORDS_PER_MINUTE.to_f).ceil,
        average_words: (total_words / posts.size.to_f).round,
        longest_post: post_info(sorted_by_words.first[0], sorted_by_words.first[1]),
        shortest_post: post_info(sorted_by_words.last[0], sorted_by_words.last[1]),
        first_post: post_info_with_date(sorted_by_date.first),
        last_post: post_info_with_date(sorted_by_date.last),
        years_active: years_active(dates.first, dates.last),
        posts_per_month: posts_per_month(posts.size, dates.first, dates.last),
        posts_by_year: posts_by_year(posts),
        posts_by_month: posts_by_month(posts),
        posts_by_day_of_week: posts_by_day_of_week(posts),
        tags: tag_counts(posts),
        categories: category_counts(posts),
        drafts_count: drafts_count
      }
    end

    def collect_posts
      posts = site.posts.docs.dup
      posts += site.drafts if include_drafts && site.respond_to?(:drafts)
      posts = filter_posts_by_tags(posts) if filter_tags
      posts
    end

    def filter_posts_by_tags(posts)
      posts.select do |post|
        post_tags = (post.data["tags"] || []).map { |t| normalize_tag(t) }
        (filter_tags & post_tags).any?
      end
    end

    def normalize_filter_tags(tags)
      return nil if tags.nil? || tags.empty?

      tags.map { |t| normalize_tag(t) }
    end

    def word_count(post)
      content = post.content.to_s
      text = content.gsub(/<[^>]*>/, " ")
      text = text.gsub(/```[\s\S]*?```/, " ")
      text = text.gsub(/`[^`]*`/, " ")
      text = text.gsub(/\[([^\]]*)\]\([^)]*\)/, '\1')
      text = text.gsub(/[#*_~`]/, "")
      text.split(/\s+/).count { |w| w.match?(/\w/) }
    end

    def post_info(post, words)
      {
        title: post.data["title"] || "(untitled)",
        url: post.url,
        words: words
      }
    end

    def post_info_with_date(post)
      {
        title: post.data["title"] || "(untitled)",
        url: post.url,
        date: post.date.strftime("%Y-%m-%d")
      }
    end

    def years_active(first_date, last_date)
      seconds = (last_date - first_date).to_f
      days = seconds / 86400.0
      (days / 365.25).round(1)
    end

    def posts_per_month(count, first_date, last_date)
      months = ((last_date.year - first_date.year) * 12) + (last_date.month - first_date.month) + 1
      (count / months.to_f).round(1)
    end

    def posts_by_year(posts)
      counts = posts.group_by { |p| p.date.year }
                    .transform_values(&:size)
                    .sort_by { |year, _| -year }
      counts.map { |year, count| { year: year, count: count } }
    end

    def posts_by_month(posts)
      counts = posts.group_by { |p| p.date.strftime("%Y-%m") }
                    .transform_values(&:size)
                    .sort_by { |month, _| month }
                    .reverse
      counts.map { |month, count| { month: month, count: count } }
    end

    def posts_by_day_of_week(posts)
      days = %w[sunday monday tuesday wednesday thursday friday saturday]
      counts = Hash.new(0)
      posts.each { |p| counts[days[p.date.wday]] += 1 }
      days.each_with_object({}) { |day, h| h[day] = counts[day] }
    end

    def tag_counts(posts)
      counts = Hash.new(0)
      posts.each do |post|
        tags = post.data["tags"] || []
        tags.each { |tag| counts[normalize_tag(tag)] += 1 }
      end
      counts.sort_by { |_, count| -count }
            .map { |name, count| { name: name, count: count } }
    end

    def normalize_tag(tag)
      tag.to_s.strip.gsub(/[,;:]+\z/, "").strip
    end

    def category_counts(posts)
      counts = Hash.new(0)
      posts.each do |post|
        categories = post.data["categories"] || []
        categories.each { |cat| counts[normalize_tag(cat)] += 1 }
      end
      counts.sort_by { |_, count| -count }
            .map { |name, count| { name: name, count: count } }
    end

    def drafts_count
      return 0 unless site.respond_to?(:drafts) && site.drafts

      site.drafts.size
    end

    def empty_stats
      {
        generated_at: Time.now.utc.iso8601,
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
        posts_by_day_of_week: %w[sunday monday tuesday wednesday thursday friday saturday].each_with_object({}) { |d, h| h[d] = 0 },
        tags: [],
        categories: [],
        drafts_count: 0
      }
    end
  end
end
