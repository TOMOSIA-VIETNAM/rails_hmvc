require 'rails/generators'
require 'rails/generators/named_base'
require_relative '../generator_helpers'

module RailsHmvc
  module Generators
    class ControllerGenerator < Rails::Generators::NamedBase
      include GeneratorHelpers

      source_root File.expand_path('templates', __dir__)

      class_option :actions, type: :array, default: %w[index show create update destroy],
                  desc: 'List of controller actions to include'
      class_option :parent, type: :string, desc: 'Parent controller class'
      class_option :version, type: :string, desc: 'API version (e.g., v1)'
      class_option :skip_operations, type: :boolean, default: false,
                  desc: 'Skip associating with operations'
      class_option :skip_forms, type: :boolean, default: false,
                  desc: 'Skip associating with forms'

      def initialize(*args)
        super
        @config = load_config
        set_defaults_from_config
      end

      def create_controller_file
        template(
          'controller.rb',
          "app/controllers/#{controller_path}.rb"
        )
      end

      private

      def set_defaults_from_config
        options[:parent] ||= @config['parent_controller']
        options[:version] ||= @config['api_version'] || 'v1'
      end

      def parent_controller_class
        options[:parent] || "#{version_class}Controller"
      end

      def version
        options[:version].downcase
      end

      def version_class
        version.camelize
      end

      def controller_path
        if class_path.empty?
          "#{version}/#{plural_name}_controller"
        else
          components = class_path.dup
          if components.first == version
            class_path.join('/') + '_controller'
          else
            "#{version}/#{components.join('/')}_controller"
          end
        end
      end

      def controller_class_name
        if class_path.empty?
          "#{version_class}::#{class_name.pluralize}Controller"
        else
          components = class_path.map(&:camelize)
          if components.first == version_class
            "#{components.join('::')}Controller"
          else
            "#{version_class}::#{components.join('::')}Controller"
          end
        end
      end

      def resource_class
        class_name
      end

      def actions
        options[:actions]
      end

      def skip_operations?
        options[:skip_operations]
      end

      def skip_forms?
        options[:skip_forms]
      end

      def operation_class_for(action)
        "#{version_class}::#{resource_class.pluralize}::#{action.camelize}Operation"
      end

      def form_class_for(action)
        return nil unless %w[create update].include?(action)
        "#{version_class}::#{resource_class.pluralize}::#{action.camelize}Form"
      end

      def serializer_class
        "#{version_class}::#{resource_class}Serializer"
      end
    end
  end
end
