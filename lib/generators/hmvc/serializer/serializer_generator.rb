require 'rails/generators'
require 'rails/generators/named_base'
require_relative '../generator_helpers'

module RailsHmvc
  module Generators
    class SerializerGenerator < Rails::Generators::NamedBase
      include GeneratorHelpers

      source_root File.expand_path('templates', __dir__)

      class_option :attributes, type: :array, default: [],
                  desc: 'List of attributes to include in the serializer'
      class_option :associations, type: :array, default: [],
                  desc: 'List of associations in the format: belongs_to:user or has_many:comments'
      class_option :parent, type: :string,
                  desc: 'Parent serializer class'
      class_option :version, type: :string,
                  desc: 'API version (e.g., v1)'

      def initialize(*args)
        super
        @config = load_config
        set_defaults_from_config
      end

      def create_serializer_file
        template(
          'serializer.rb',
          "app/serializers/#{serializer_path}.rb"
        )
      end

      private

      def set_defaults_from_config
        @options = options.dup

        @options[:parent] ||= @config['parent_serializer']
        @options[:version] ||= @config['api_version'] || 'v1'
      end

      def serializer_path
        if class_path.empty?
          "#{version}/#{singular_name}_serializer"
        else
          if class_path.first == version
            "#{class_path.join('/')}_serializer"
          else
            "#{version}/#{class_path.join('/')}_serializer"
          end
        end
      end

      def serializer_class_name
        if class_path.empty?
          "#{version_class}::#{class_name}Serializer"
        else
          if class_path.first == version
            components = class_path.map(&:camelize)
            "#{components.join('::')}Serializer"
          else
            components = class_path.map(&:camelize)
            "#{version_class}::#{components.join('::')}Serializer"
          end
        end
      end

      def version
        @options[:version].downcase
      end

      def version_class
        version.camelize
      end

      def parent_serializer_class
        @options[:parent] || 'MainSerializer'
      end

      def attributes_list
        ['id', 'created_at', 'updated_at'] + @options[:attributes]
      end

      def parse_associations
        result = { belongs_to: [], has_many: [], has_one: [] }

        @options[:associations].each do |assoc|
          type, name = assoc.split(':')

          if %w[belongs_to has_many has_one].include?(type) && name.present?
            result[type.to_sym] << name
          end
        end

        result
      end
    end
  end
end
