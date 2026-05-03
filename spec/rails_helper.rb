# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"

Rails.application.load_generators

require "errors/base_error"
require "errors/api_error"
require "errors/resource_error"

require "generator_spec"

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.include GeneratorSpec::GeneratorExampleGroup, type: :generator

  config.define_derived_metadata(file_path: %r{/spec/generators/}) do |meta|
    meta[:type] = :generator
  end
end
