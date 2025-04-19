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

      def initialize(*args)
        super
        @form_attributes = parse_attributes(options[:attributes])
        @form_validations = parse_validations(options[:validations])
        @parent_class = determine_parent_class
      end

      def create_form_file
        template(
          'form.rb',
          File.join('app/forms', class_path, "#{file_name}_form.rb")
        )
      end

      private

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

          if options&.start_with?('{') && options&.end_with?('}')
            # Handle hash options like length:{maximum:100}
            options_content = options[1..-2] # Remove { and }
            options_parts = []

            # Parse key-value pairs
            current_part = ""
            nesting_level = 0

            options_content.each_char.with_index do |char, i|
              if char == '{'
                nesting_level += 1
                current_part += char
              elsif char == '}'
                nesting_level -= 1
                current_part += char
              elsif char == ',' && nesting_level == 0
                options_parts << current_part.strip
                current_part = ""
              else
                current_part += char
              end
            end

            options_parts << current_part.strip if current_part.strip.length > 0

            # Format options
            formatted_options = options_parts.map do |opt|
              if opt.include?(':')
                key, value = opt.split(':', 2)
                "#{key}: #{value}"
              else
                opt
              end
            end.join(', ')

            result[attr] << "#{type}: {#{formatted_options}}"
          else
            # Handle simple options like presence:true
            result[attr] << "#{type}: #{options || true}"
          end
        end
        result
      end

      def determine_parent_class
        options[:parent] || load_config.dig('parent_form') || 'ApplicationForm'
      end

      def form_class_name
        "#{class_name}Form"
      end

      def namespaced_class_name
        if class_path.empty?
          form_class_name
        else
          class_parts = class_path.dup
          # Nếu path là v1/posts/create thì class name sẽ là V1::Posts::CreateForm
          namespace = class_parts.map(&:camelize)
          resource_name = namespace.pop # Lấy tên resource (create)
          "#{namespace.join('::')}::#{resource_name.camelize}Form"
        end
      end

      def parent_class_name
        if @parent_class.include?('::')
          @parent_class
        else
          "::#{@parent_class}"
        end
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
