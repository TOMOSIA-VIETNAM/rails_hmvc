# frozen_string_literal: true

module RailsHmvc
  module Generators
    class OperationGenerator < Rails::Generators::NamedBase
      namespace "hmvc:operation"

      include GeneratorHelpers

      source_root File.expand_path("templates", __dir__)

      class_option :type, type: :string, desc: "Project type (api/web)"
      class_option :parent, type: :string, desc: "Parent operation class"
      class_option :steps, type: :string, desc: "List of step methods"
      class_option :actions, type: :string, desc: "List of operations to generate (e.g., index,create)"

      def initialize(*args)
        super
        @config = load_config_for_type(options[:type])
        @operations_config = @config["operations"]
        set_defaults_from_config
      end

      def create_operations
        return create_single_operation if actions.empty?

        actions.each do |action|
          create_operation_for(action)
        end
      end

      private

      def set_defaults_from_config
        @options = options.dup
        @options[:type]   ||= @config["type"]
        @options[:parent] ||= @operations_config["parent"]
        @options[:steps]  ||= @operations_config["steps"]
        @options[:actions] ||= [] # Do not set default actions here. Because it will override from user input.
      end

      def actions
        return [] if @options[:actions].nil?
        return @options[:actions].split(",") if @options[:actions].is_a?(String)

        @options[:actions]
      end

      def create_single_operation
        template(
          "operation.rb",
          "app/operations/#{namespace_path}/#{operation_path}.rb"
        )
      end

      def create_operation_for(action)
        @current_action = action
        template(
          "operation.rb",
          "app/operations/#{namespace_path}/#{plural_name}/#{action}_operation.rb"
        )
      end

      def operation_path
        if @current_action
          "#{plural_name}/#{@current_action}_operation"
        else
          "#{operation_class_name.underscore}_operation"
        end
      end

      def operation_class_name
        if @current_action
          @current_action.camelize
        else
          file_name.camelize
        end
      end

      def parent_operation_class
        @options[:parent]
      end

      def steps
        return [] if @options[:steps].nil?
        return @options[:steps].split(",") if @options[:steps].is_a?(String)

        Array(@options[:steps])
      end

      def step_methods
        steps.map do |method_name|
          method_name.to_s.start_with?("step_") ? method_name.to_sym : :"step_#{method_name}"
        end
      end
    end
  end
end
