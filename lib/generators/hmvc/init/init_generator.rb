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
        ].each do |dir|
          empty_directory dir
        end
      end

      def create_configuration_file
        template 'config/rails_hmvc.yml.tt', 'config/rails_hmvc.yml'
      end

      def modify_application_rb
        inject_into_file 'config/application.rb', after: "class Application < Rails::Application\n" do
          <<-RUBY
    # Load HMVC configuration
    config.before_configuration do
      rails_hmvc_config = Rails.root.join('config', 'rails_hmvc.yml')
      if File.exist?(rails_hmvc_config)
        begin
          config_content = YAML.safe_load(File.read(rails_hmvc_config))
          config_env = config_content[Rails.env] || {}

          config_env.each do |key, value|
            config.send("\#{key}=", value) if config.respond_to?("\#{key}=")
          end
        rescue => e
          puts "Warning: Error loading rails_hmvc.yml: \#{e.message}"
        end
      end
    end

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
        route "scope module: :v1, path: 'v1' do\n  # V1 API routes go here\nend"
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
