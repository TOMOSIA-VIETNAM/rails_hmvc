require 'rails/generators'
require 'rails/generators/named_base'
require_relative '../generator_helpers'

module RailsHmvc
  module Generators
    class FormGenerator < Rails::Generators::NamedBase
      include GeneratorHelpers

      source_root File.expand_path('templates', __dir__)

      class_option :type, type: :string, desc: 'Project type (api/web)'
      class_option :parent, type: :string, desc: 'Parent class to inherit from'
      class_option :attributes, type: :string, desc: 'List of attributes in the format: name:type'
      class_option :actions, type: :string, desc: 'List of forms to generate (e.g., create,update)'

      def initialize(*args)
        super
        @config = load_config_for_type(options[:type])
        @forms_config = @config['forms']
        @form_attributes = parse_attributes(options[:attributes])
        set_defaults_from_config
      end

      def create_forms
        if actions.empty?
          say "❌ Error: No actions specified for form generation.", :red
          say "Forms must be generated for specific RESTful actions.", :yellow
          say "Usage examples:", :blue
          say "  rails g rails_hmvc:form #{name} --actions=create,update", :blue
          say "  rails g rails_hmvc:form #{name} --actions=create", :blue
          say "Available actions: create, update, new, edit", :blue
          exit 1
        end

        actions.each do |action|
          create_form_for(action)
        end
      end

      private

      def set_defaults_from_config
        @options = options.dup
        @options[:type] ||= @config['type']
        @options[:parent] ||= @forms_config['parent']
        @options[:actions] ||= [] # Do not set default actions here. Because it will override from user input.
      end

      def actions
        return [] if @options[:actions].nil?
        return @options[:actions].split(',') if @options[:actions].is_a?(String)
        @options[:actions]
      end

      def create_form_for(action)
        @current_action = action
        template(
          'form.rb',
          "app/forms/#{namespace_path}/#{singular_name}/#{action}_form.rb"
        )
      end

      def form_class_name
        @current_action.camelize
      end

      def parent_form_class
        @options[:parent]
      end

      def parse_attributes(attrs)
        if attrs.nil?
          [{ prop: :name, type: 'string' }]
        else
          attrs.split(',').map do |attr|
            prop, type = attr.split(':')
            { prop: prop, type: type }
          end
        end
      end

      def attribute_definitions
        return if @form_attributes.nil?

        @form_attributes.map do |attr|
          if attr[:type].nil?
            "  attribute :#{attr[:prop]}"
          else
            "  attribute :#{attr[:prop]}, :#{attr[:type]}"
          end
        end.join("\n")
      end

      def namespace_path
        # Extract namespace from class_path if it exists
        class_path.empty? ? "" : class_path.join("/")
      end

      def namespace_name
        # Create namespace for class name - use singular class name
        if class_path.empty?
          singular_name.camelize
        else
          (class_path + [singular_name]).map(&:camelize).join("::")
        end
      end
    end
  end
end
