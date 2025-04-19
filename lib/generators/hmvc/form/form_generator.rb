require 'rails/generators'
require 'rails/generators/named_base'
require_relative '../generator_helpers'

module RailsHmvc
  module Generators
    class FormGenerator < Rails::Generators::NamedBase
      include GeneratorHelpers

      source_root File.expand_path('templates', __dir__)

      class_option :attributes, type: :array, default: [],
                  desc: 'List of attributes in the format: name:type'

      class_option :validations, type: :array, default: [],
                  desc: 'List of validations in the format: attribute:validation_type:options'

      class_option :parent, type: :string,
                  desc: 'Parent class to inherit from'

      class_option :type, type: :string, desc: 'Project type (api/web)'

      def initialize(*args)
        super
        @config = load_config_for_type(options[:type])
        @resource_config = get_resource_config('forms')
        @form_attributes = parse_attributes(options[:attributes])
        @form_validations = parse_validations(options[:validations])
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
        # Tạo một bản sao của options để tránh lỗi frozen hash
        @options = options.dup

        @options[:parent] ||= @config['parent_form']

        # Kiểm tra xem có nên skip action này không
        if @resource_config['skip_actions']&.include?(file_name)
          say_status :skip, "Skipping form for action #{file_name} (configured in rails_hmvc.yml)", :yellow
          exit
        end
      end

      def parse_attributes(attrs)
        attrs.map do |attr|
          name, type = attr.split(':')
          { name: name, type: type || 'string' }
        end
      end

      def parse_validations(validations)
        result = {}
        validations.each do |validation|
          attr, type, options = validation.split(':')
          result[attr] ||= []

          # Handle simple options like presence:true
          result[attr] << "#{type}: #{options || true}"
        end
        result
      end

      def parent_form_class
        @options[:parent] || 'MainForm'
      end

      def form_class_name
        file_name.camelize
      end

      def attribute_definitions
        @form_attributes.map do |attr|
          "  attribute :#{attr[:name]}, :#{attr[:type]}"
        end.join("\n")
      end

      def validation_definitions
        @form_validations.map do |attr, validations|
          "  validates :#{attr}, #{validations.join(', ')}"
        end.join("\n")
      end
    end
  end
end
