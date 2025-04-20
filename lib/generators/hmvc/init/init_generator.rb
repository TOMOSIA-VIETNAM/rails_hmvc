module RailsHmvc
  module Generators
    class InitGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_hmvc_directories
        %w[
          app/controllers
          app/operations
          app/forms
          app/serializers
          app/models
          lib/errors
          app/controllers/concerns
          config/initializers
        ].each do |dir|
          empty_directory dir
        end
      end

      def create_configuration_file
        template 'config/rails_hmvc.yml.tt', 'config/rails_hmvc.yml'
      end

      def create_initializer
        template 'config/initializers/rails_hmvc.rb.tt', 'config/initializers/rails_hmvc.rb'
      end

      def modify_application_rb
        inject_into_file 'config/application.rb', after: "class Application < Rails::Application\n" do
          <<-RUBY
    # Autoload lib directory
    config.autoload_paths += %W[\#{config.root}/lib]

    # Configure generators
    config.generators do |g|
      g.template_engine nil
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end
          RUBY
        end
      end

      def create_base_error_class
        template 'errors/application_error.rb.tt', 'lib/errors/application_error.rb'
        template 'errors/resource_error.rb.tt', 'lib/errors/resource_error.rb'
      end

      def create_base_classes
        template 'controllers/main_controller.rb.tt', 'app/controllers/main_controller.rb'
        template 'controllers/api_controller.rb.tt', 'app/controllers/api_controller.rb'
        template 'forms/main_form.rb.tt', 'app/forms/main_form.rb'
        template 'operations/main_operation.rb.tt', 'app/operations/main_operation.rb'
      end

      def add_routes
        route "# Default API routes\n# Customize paths based on your application needs"
      end

      def create_concerns
        template 'concerns/renderable.rb.tt', 'app/controllers/concerns/renderable.rb'
        template 'concerns/errorable.rb.tt', 'app/controllers/concerns/errorable.rb'
      end

      def create_serializers
        template 'serializers/main_serializer.rb.tt', 'app/serializers/main_serializer.rb'
        template 'errors/error_serializer.rb.tt', 'app/serializers/error_serializer.rb'
      end

      private

      def app_name
        Rails.application.class.name.split('::').first
      end
    end
  end
end
