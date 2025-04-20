module RailsHmvc
  module Generators
    class OperationGenerator < Rails::Generators::NamedBase
      include GeneratorHelpers

      source_root File.expand_path('templates', __dir__)

      class_option :type, type: :string, desc: 'Project type (api/web)'
      class_option :parent, type: :string, desc: 'Parent operation class'
      class_option :steps, type: :string, desc: 'List of step methods'

      def initialize(*args)
        super
        @config = load_config_for_type(options[:type])
        @operations_config = @config['operations']
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
        @options = options.dup
        @options[:type]   ||= @config['type']
        @options[:parent] ||= @operations_config['parent']
        @options[:steps]  ||= @operations_config['steps']
      end

      def parent_operation_class
        @options[:parent]
      end

      def operation_class_name
        file_name.camelize
      end

      def steps
        return [] if @options[:steps].nil?
        return @options[:steps].split(',') if @options[:steps].is_a?(String)

        Array(@options[:steps])
      end

      def step_methods
        steps.map do |method_name|
          method_name.to_s.start_with?('step_') ? method_name.to_sym : :"step_#{method_name}"
        end
      end
    end
  end
end
