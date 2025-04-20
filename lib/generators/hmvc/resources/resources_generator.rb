module RailsHmvc
  module Generators
    class ResourcesGenerator < Rails::Generators::NamedBase
      include GeneratorHelpers

      source_root File.expand_path('templates', __dir__)

      class_option :type, type: :string, desc: 'Project type (api/web)'
      class_option :parent_controller, type: :string, desc: 'Parent controller class'
      class_option :parent_operation, type: :string, desc: 'Parent operation class'
      class_option :parent_form, type: :string, desc: 'Parent form class'
      class_option :actions, type: :array, desc: 'List of actions to generate'

      def initialize(*args)
        super
        @config = load_config_for_type(options[:type])
        @controllers_config = get_resource_config('controllers')
        @operations_config = get_resource_config('operations')
        @forms_config = get_resource_config('forms')
        set_defaults_from_config
      end

      def create_controller
        args = [
          name,
          "--type=#{options[:type]}",
          "--parent=#{parent_controller_class}"
        ]

        args << "--actions=#{actions.join(',')}" if actions.any?

        Rails::Generators.invoke "rails_hmvc:controller", args, behavior: behavior
      end

      def create_operations
        actions.each do |action|
          args = [
            "#{namespace_path}/#{plural_name}/#{action}",
            "--type=#{options[:type]}",
            "--parent=#{parent_operation_class}"
          ]

          Rails::Generators.invoke "rails_hmvc:operation", args, behavior: behavior
        end
      end

      def create_forms
        form_actions = @forms_config['actions'] || %w[create update]
        skip_actions = @forms_config['skip_actions'] || []

        form_actions.each do |action|
          next if skip_actions.include?(action)
          next unless actions.include?(action)

          args = [
            "#{namespace_path}/#{plural_name}/#{action}",
            "--type=#{options[:type]}",
            "--parent=#{parent_form_class}"
          ]

          Rails::Generators.invoke "rails_hmvc:form", args, behavior: behavior
        end
      end

      private

      def actions
        @actions ||= options[:actions] || @controllers_config['actions'] || %w[index show create update destroy]
      end

      def set_defaults_from_config
        @options = options.dup

        @options[:type] ||= @config['type'] || 'api'
        @options[:parent_controller] ||= @config['parent_controller']
        @options[:parent_operation] ||= @config['parent_operation']
        @options[:parent_form] ||= @config['parent_form']
      end

      def parent_controller_class
        @options[:parent_controller] || "#{namespace_name.split('::').first}Controller"
      end

      def parent_operation_class
        @options[:parent_operation] || @config['parent_operation'] || 'MainOperation'
      end

      def parent_form_class
        @options[:parent_form] || @config['parent_form'] || 'MainForm'
      end
    end
  end
end
