# frozen_string_literal: true

require "test_helper"
require "json"
require "fileutils"
require "mercenary"

class CommandTest < Minitest::Test
  include JekyllStats::TestHelpers

  def setup
    cleanup_fixtures
    create_post("2024-01-15-test.md", "This is test content for the command.", "title" => "Test Post")
  end

  def teardown
    cleanup_fixtures
    data_file = File.join(fixture_path, "_data", "stats.json")
    FileUtils.rm_f(data_file)
    FileUtils.rm_rf(File.join(fixture_path, "_data"))
  end

  def test_command_registers_with_jekyll
    prog = Mercenary::Program.new(:jekyll)
    JekyllStats::Command.init_with_program(prog)

    stats_command = prog.commands[:stats]
    refute_nil stats_command
    assert_equal :stats, stats_command.name
  end

  def test_command_has_save_option
    prog = Mercenary::Program.new(:jekyll)
    JekyllStats::Command.init_with_program(prog)

    stats_command = prog.commands[:stats]
    option_names = stats_command.options.map { |o| o.config_key }
    assert_includes option_names, "save"
  end

  def test_command_has_json_option
    prog = Mercenary::Program.new(:jekyll)
    JekyllStats::Command.init_with_program(prog)

    stats_command = prog.commands[:stats]
    option_names = stats_command.options.map { |o| o.config_key }
    assert_includes option_names, "json"
  end

  def test_command_has_drafts_option
    prog = Mercenary::Program.new(:jekyll)
    JekyllStats::Command.init_with_program(prog)

    stats_command = prog.commands[:stats]
    option_names = stats_command.options.map { |o| o.config_key }
    assert_includes option_names, "drafts"
  end

  def test_command_has_tags_option
    prog = Mercenary::Program.new(:jekyll)
    JekyllStats::Command.init_with_program(prog)

    stats_command = prog.commands[:stats]
    option_names = stats_command.options.map { |o| o.config_key }
    assert_includes option_names, "tags"
  end

  def test_save_creates_data_directory
    options = {
      "source" => fixture_path,
      "destination" => File.join(fixture_path, "_site"),
      "skip_config_files" => true,
      "save" => true
    }

    capture_io do
      JekyllStats::Command.process(options)
    end

    assert File.directory?(File.join(fixture_path, "_data"))
  end

  def test_save_writes_json_file
    options = {
      "source" => fixture_path,
      "destination" => File.join(fixture_path, "_site"),
      "skip_config_files" => true,
      "save" => true
    }

    capture_io do
      JekyllStats::Command.process(options)
    end

    json_path = File.join(fixture_path, "_data", "stats.json")
    assert File.exist?(json_path)

    data = JSON.parse(File.read(json_path))
    assert_equal 1, data["total_posts"]
  end

  def test_json_output_is_valid_json
    options = {
      "source" => fixture_path,
      "destination" => File.join(fixture_path, "_site"),
      "skip_config_files" => true,
      "json" => true
    }

    output, _err = capture_io do
      JekyllStats::Command.process(options)
    end

    # The output might have Jekyll log messages, find the JSON part
    json_start = output.index("{")
    json_end = output.rindex("}")
    json_str = output[json_start..json_end]

    data = JSON.parse(json_str)
    assert_equal 1, data["total_posts"]
    assert data.key?("generated_at")
  end
end
