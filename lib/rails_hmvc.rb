# frozen_string_literal: true

require 'rails_hmvc/version'
require 'rails'
require 'active_model'
require 'active_model_serializers'

module RailsHmvc
  class Error < StandardError; end

  if defined?(Rails::Railtie)
    class Railtie < Rails::Railtie
      generators do
        require_relative 'generators/hmvc/generator_helpers'
        require_relative 'generators/hmvc/init/init_generator'
        require_relative 'generators/hmvc/form/form_generator'
        require_relative 'generators/hmvc/operation/operation_generator'
        require_relative 'generators/hmvc/controller/controller_generator'
        require_relative 'generators/hmvc/serializer/serializer_generator'
      end
    end
  end
end
