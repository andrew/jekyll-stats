# frozen_string_literal: true

require_relative "lib/jekyll-stats/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-stats"
  spec.version = JekyllStats::VERSION
  spec.authors = ["Andrew Nesbitt"]
  spec.email = ["andrewnez@gmail.com"]

  spec.summary = "Jekyll plugin that generates site statistics"
  spec.description = "Adds a 'jekyll stats' command that computes and displays site statistics including post counts, word counts, reading times, tag/category distributions, and posting frequency."
  spec.homepage = "https://github.com/andrew/jekyll-stats"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ .git .github Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", ">= 4.0"
  spec.add_dependency "logger"
end
