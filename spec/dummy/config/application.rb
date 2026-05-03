# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    # 6.1 defaults are safe to load on any higher Rails version
    config.load_defaults 6.1
    config.root = File.expand_path("..", __dir__)
    config.generators.system_tests = nil
    config.active_record.maintain_test_schema = false if defined?(ActiveRecord)
  end
end
