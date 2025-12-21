# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "jekyll"
require "jekyll-stats"
require "minitest/autorun"

module JekyllStats
  module TestHelpers
    def fixture_site(options = {})
      config = Jekyll.configuration(
        "source" => fixture_path,
        "destination" => File.join(fixture_path, "_site"),
        "skip_config_files" => true
      ).merge(options)

      site = Jekyll::Site.new(config)
      site.reset
      site.read
      site
    end

    def fixture_path
      File.expand_path("fixtures", __dir__)
    end

    def create_post(filename, content, frontmatter = {})
      posts_dir = File.join(fixture_path, "_posts")
      FileUtils.mkdir_p(posts_dir)

      fm = { "title" => "Test Post", "date" => "2024-01-15" }.merge(frontmatter)
      fm_yaml = fm.map { |k, v| "#{k}: #{v.is_a?(Array) ? "\n  - #{v.join("\n  - ")}" : v}" }.join("\n")

      File.write(File.join(posts_dir, filename), "---\n#{fm_yaml}\n---\n\n#{content}")
    end

    def cleanup_fixtures
      posts_dir = File.join(fixture_path, "_posts")
      FileUtils.rm_rf(posts_dir)
      FileUtils.rm_rf(File.join(fixture_path, "_site"))
    end
  end
end
