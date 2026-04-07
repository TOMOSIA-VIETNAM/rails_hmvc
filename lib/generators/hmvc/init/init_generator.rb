require 'rails/generators'

module RailsHmvc
  module Generators
    class InitGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      class_option :type, type: :string, default: "api", desc: "Project type (api/web)"
      class_option :views, type: :boolean, default: false, desc: "Generate views structure for web type"

      def create_hmvc_directories
        base_dirs = %w[
          app/controllers
          app/operations
          app/forms
          app/serializers
          app/models
          lib/errors
          app/controllers/concerns
          config/initializers
        ]

        # Add views directory for web type or when --views option is used
        base_dirs << "app/views" if web_type? || generate_views?

        base_dirs.each do |dir|
          empty_directory dir
        end
      end

      def create_configuration_file
        template "config/rails_hmvc.yml.tt", "config/rails_hmvc.yml"
      end

      # def create_initializer
      #   template 'config/initializers/rails_hmvc.rb.tt', 'config/initializers/rails_hmvc.rb'
      # end

      def create_base_error_class
        template "errors/application_error.rb.tt", "lib/errors/application_error.rb"
        template "errors/resource_error.rb.tt", "lib/errors/resource_error.rb"
      end

      def create_base_classes
        template "controllers/main_controller.rb.tt", "app/controllers/main_controller.rb"
        template "controllers/api_controller.rb.tt", "app/controllers/api_controller.rb"
        template "forms/main_form.rb.tt", "app/forms/main_form.rb"
        template "operations/main_operation.rb.tt", "app/operations/main_operation.rb"
      end

      def create_concerns
        template "concerns/renderable.rb.tt", "app/controllers/concerns/renderable.rb"
        template "concerns/errorable.rb.tt", "app/controllers/concerns/errorable.rb"
      end

      def create_serializers
        template "serializers/main_serializer.rb.tt", "app/serializers/main_serializer.rb"
        template "errors/error_serializer.rb.tt", "app/serializers/error_serializer.rb"
      end

      def create_views_structure
        return unless web_type? || generate_views?

        # Create shared layout directory
        empty_directory "app/views/layouts"
        empty_directory "app/views/shared"

        say "Views basic structure created (layouts, shared)", :green
        say "Use 'rails g rails_hmvc:controller resource --views' to generate specific views", :blue
      end

      private

      def app_name
        Rails.application.class.name.split("::").first
      end

      def web_type?
        options[:type] == "web"
      end

      def generate_views?
        options[:views]
      end
    end
  end
end
