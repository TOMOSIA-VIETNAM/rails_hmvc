module RailsHmvc
  module Generators
    class OperationGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      class_option :version, type: :string, default: 'v1', desc: 'API version'
      class_option :parent, type: :string, desc: 'Parent operation class'
      class_option :steps, type: :array, default: [], desc: 'Operation steps to include'
      class_option :resource, type: :string, desc: 'Resource name (e.g., posts for PostsController)'

      def initialize(*args)
        super
        @config = load_config
        set_defaults_from_config
      end

      def create_operation
        @steps = options[:steps].presence || ['process']
        @resource = options[:resource].presence || name.split('/').first

        template(
          'operation.rb',
          "app/operations/#{version}/#{operation_path}.rb"
        )
      end

      private

      def version
        options[:version]
      end

      def operation_path
        if @resource.present?
          "#{@resource.pluralize}/#{operation_name}_operation"
        else
          "#{operation_name}_operation"
        end
      end

      def operation_name
        name.split('/').last
      end

      def operation_class_name
        operation_name.camelize
      end

      def resource_class_name
        @resource.classify
      end

      def namespace_path
        if @resource.present?
          "#{version.camelize}::#{resource_class_name.pluralize}"
        else
          class_parts = class_path.dup
          namespace = class_parts.map(&:camelize)
          namespace.pop
          namespace.join('::')
        end
      end

      def load_config
        config_file = Rails.root.join('config', 'rails_hmvc.yml')
        return {} unless File.exist?(config_file)

        YAML.load_file(config_file)[Rails.env] || {}
      end

      def set_defaults_from_config
        options[:parent] ||= @config['parent_operation']
      end

      def parent_operation_class
        options[:parent] || 'MainOperation'
      end
    end
  end
end
