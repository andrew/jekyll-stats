# frozen_string_literal: true

require "json"
require "fileutils"

module JekyllStats
  class Command < Jekyll::Command
    class << self
      def init_with_program(prog)
        prog.command(:stats) do |c|
          c.syntax "stats [options]"
          c.description "Display site statistics"
          c.option "save", "--save", "Save stats to _data/stats.json"
          c.option "json", "--json", "Output raw JSON to stdout"
          c.option "drafts", "-D", "--drafts", "Include drafts in calculations"
          c.option "config", "--config CONFIG_FILE[,CONFIG_FILE2,...]", Array, "Custom configuration file"
          c.option "source", "-s", "--source SOURCE", "Custom source directory"
          c.option "destination", "-d", "--destination DESTINATION", "Custom destination directory"

          c.action do |_args, options|
            process(options)
          end
        end
      end

      def process(options)
        options = configuration_from_options(options)
        site = Jekyll::Site.new(options)

        Jekyll.logger.info "Loading site..."
        site.reset
        site.read

        calculator = StatsCalculator.new(site, include_drafts: options["drafts"])
        stats = calculator.calculate

        if options["json"]
          puts JSON.pretty_generate(stats)
        else
          formatter = Formatter.new(stats)
          puts formatter.to_terminal

          if options["save"]
            save_stats(site, stats)
          end
        end
      end

      def save_stats(site, stats)
        data_dir = File.join(site.source, "_data")
        FileUtils.mkdir_p(data_dir)

        path = File.join(data_dir, "stats.json")
        File.write(path, JSON.pretty_generate(stats))
        Jekyll.logger.info "Stats saved to #{path}"
      end
    end
  end
end
