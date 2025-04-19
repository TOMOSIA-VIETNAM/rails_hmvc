module RailsHmvc
  module Generators
    class OperationGenerator < Rails::Generators::NamedBase
      include GeneratorHelpers

      source_root File.expand_path('templates', __dir__)

      class_option :parent, type: :string, desc: 'Parent operation class'
      class_option :type, type: :string, desc: 'Project type (api/web)'

      def initialize(*args)
        super
        @config = load_config_for_type(options[:type])
        @resource_config = get_resource_config('operations')
        set_defaults_from_config
      end

      def create_operation
        template(
          'operation.rb',
          "app/operations/#{namespace_path}/#{operation_class_name.underscore}_operation.rb"
        )
      end

      private

      def set_defaults_from_config
        # Tạo một bản sao của options để tránh lỗi frozen hash
        @options = options.dup

        @options[:parent] ||= @config['parent_operation']
      end

      def parent_operation_class
        @options[:parent] || 'MainOperation'
      end

      def operation_class_name
        file_name.camelize
      end
    end
  end
end
