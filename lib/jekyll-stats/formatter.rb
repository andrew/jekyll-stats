# frozen_string_literal: true

module JekyllStats
  class Formatter
    attr_reader :stats

    def initialize(stats)
      @stats = stats
    end

    def to_terminal
      return "No posts found." if stats[:total_posts].zero?

      lines = []
      lines << ""
      lines << "\u{1F4CA} Site Statistics"
      lines << "\u2500" * 35

      lines << post_summary
      lines << averages_line
      lines << date_range_line
      lines << frequency_line

      lines << ""
      lines << posts_by_year_chart

      if stats[:tags].any?
        lines << ""
        lines << top_tags
      end

      if stats[:categories].any?
        lines << ""
        lines << categories_line
      end

      if stats[:drafts_count].positive?
        lines << ""
        lines << "Drafts: #{stats[:drafts_count]}"
      end

      lines << "\u2500" * 35
      lines << ""

      lines.join("\n")
    end

    def post_summary
      total = stats[:total_posts]
      words = format_number(stats[:total_words])
      time = format_reading_time(stats[:reading_minutes])
      "Posts: #{total} (#{words} words, ~#{time} read time)"
    end

    def averages_line
      avg = stats[:average_words]
      longest = stats[:longest_post]
      "Avg: #{avg} words | Longest: \"#{truncate(longest[:title], 30)}\" (#{format_number(longest[:words])} words)"
    end

    def date_range_line
      first = stats[:first_post][:date]
      last = stats[:last_post][:date]
      years = stats[:years_active]
      "First: #{first} | Last: #{last} (#{years} years)"
    end

    def frequency_line
      "Frequency: #{stats[:posts_per_month]} posts/month"
    end

    def posts_by_year_chart
      years = stats[:posts_by_year]
      return "" if years.empty?

      max_count = years.map { |y| y[:count] }.max
      bar_width = 20

      lines = ["Posts by Year:"]
      years.first(10).each do |year_data|
        year = year_data[:year]
        count = year_data[:count]
        bar_length = ((count.to_f / max_count) * bar_width).round
        bar = "\u2588" * bar_length
        lines << "  #{year}: #{bar} #{count}"
      end
      lines.join("\n")
    end

    def top_tags
      tags = stats[:tags].first(10)
      tag_strs = tags.map { |t| "#{t[:name]} (#{t[:count]})" }
      "Top #{[10, stats[:tags].size].min} Tags:\n  #{tag_strs.join(" | ")}"
    end

    def categories_line
      cats = stats[:categories]
      cat_strs = cats.map { |c| "#{c[:name]} (#{c[:count]})" }
      "Categories:\n  #{cat_strs.join(" | ")}"
    end

    def format_number(n)
      n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end

    def format_reading_time(minutes)
      if minutes >= 60
        hours = minutes / 60
        mins = minutes % 60
        "#{hours}h #{mins}m"
      else
        "#{minutes}m"
      end
    end

    def truncate(str, length)
      return str if str.length <= length

      "#{str[0, length]}..."
    end
  end
end
