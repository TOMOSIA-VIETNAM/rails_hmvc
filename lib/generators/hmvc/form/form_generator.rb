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

      def initialize(*args)
        super
        @config           = load_config_for_type(options[:type])
        @forms_config     = @config['forms']
        @form_attributes  = parse_attributes(options[:attributes])
        set_defaults_from_config
      end

      def create_form_file
        template(
          'form.rb',
          File.join('app/forms', class_path, "#{file_name}_form.rb")
        )
      end

      private

      def set_defaults_from_config
        @options = options.dup
        @options[:type]   ||= @config['type']
        @options[:parent] ||= @forms_config['parent']
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

      def parent_form_class
        @options[:parent]
      end

      def form_class_name
        file_name.camelize
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
    end
  end
end
