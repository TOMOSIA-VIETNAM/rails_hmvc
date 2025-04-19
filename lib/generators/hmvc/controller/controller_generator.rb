require 'rails/generators'
require 'rails/generators/named_base'
require_relative '../generator_helpers'

module RailsHmvc
  module Generators
    class ControllerGenerator < Rails::Generators::NamedBase
      include GeneratorHelpers

      source_root File.expand_path('templates', __dir__)

      class_option :actions, type: :array, desc: 'List of controller actions to include'
      class_option :parent, type: :string, desc: 'Parent controller class'
      class_option :type, type: :string, desc: 'Project type (api/web)'
      class_option :skip_operations, type: :boolean, default: false,
                  desc: 'Skip associating with operations'
      class_option :skip_forms, type: :boolean, default: false,
                  desc: 'Skip associating with forms'

      def initialize(*args)
        super
        @config = load_config_for_type(options[:type])
        @resource_config = get_resource_config('controllers')
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
        options[:actions] ||= @resource_config['actions'] || %w[index show create update destroy]
      end

      def parent_controller_class
        options[:parent] || "#{namespace_name.split('::').first}Controller"
      end

      def controller_path
        "#{namespace_path}/#{plural_name}_controller"
      end

      def controller_class_name
        "#{namespace_name}::#{class_name.pluralize}Controller"
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
        "#{namespace_name}::#{resource_class.pluralize}::#{action.camelize}Operation"
      end

      def form_class_for(action)
        return nil unless %w[create update].include?(action)
        "#{namespace_name}::#{resource_class.pluralize}::#{action.camelize}Form"
      end

      def serializer_class
        "#{namespace_name}::#{resource_class}Serializer"
      end
    end
  end
end
