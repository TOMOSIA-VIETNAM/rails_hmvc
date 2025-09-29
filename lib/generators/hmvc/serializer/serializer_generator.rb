# lib/generators/hmvc/serializer/serializer_generator.rb

require 'rails/generators'
require 'rails/generators/named_base'
require_relative '../generator_helpers'

module RailsHmvc
  module Generators
    class SerializerGenerator < Rails::Generators::NamedBase
      include GeneratorHelpers

      source_root File.expand_path('templates', __dir__)

      class_option :type, type: :string, desc: 'Project type (api/web)'
      class_option :parent, type: :string, desc: 'Parent serializer class'
      class_option :attributes, type: :string, desc: 'List of attributes to expose (e.g., id,name,email)'
      class_option :actions, type: :string, desc: 'List of serializers to generate (e.g., index,detail,info,basic,...)'
      class_option :associations, type: :string, desc: 'List of associations to include (e.g., comments,user)'

      def initialize(*args)
        super
        @config = load_config_for_type(options[:type])
        @serializers_config = @config['serializers'] || {}
        @serializer_attributes = parse_attributes(options[:attributes])
        @serializer_associations = parse_associations(options[:associations])
        set_defaults_from_config
      end

      def create_serializers
        return create_single_serializer if actions.empty?

        actions.each do |action|
          create_serializer_for(action)
        end
      end

      private

      def set_defaults_from_config
        @options = options.dup
        @options[:type]   ||= @config['type']
        @options[:parent] ||= @serializers_config['parent'] || 'ApplicationSerializer'
        @options[:actions] ||= []
      end

      def actions
        return [] if @options[:actions].nil?
        return @options[:actions].split(',') if @options[:actions].is_a?(String)

        @options[:actions]
      end

      def create_single_serializer
        template(
          'serializer.rb',
          "app/serializers/#{namespace_path}/#{serializer_path}.rb"
        )
      end

      def create_serializer_for(action)
        @current_action = action
        template(
          'serializer.rb',
          "app/serializers/#{namespace_path}/#{plural_name}/#{action}_serializer.rb"
        )
      end

      def serializer_path
        if @current_action
          "#{plural_name}/#{@current_action}_serializer"
        else
          "#{serializer_class_name.underscore}_serializer"
        end
      end

      def serializer_class_name
        if @current_action
          @current_action.camelize
        else
          file_name.camelize
        end
      end

      def parent_serializer_class
        @options[:parent]
      end

      def parse_attributes(attrs)
        return [] if attrs.nil?

        attrs.split(',').map(&:strip)
      end

      def parse_associations(assocs)
        return [] if assocs.nil?

        assocs.split(',').map(&:strip)
      end

      def association_definitions
        return '' if @serializer_associations.empty?

        @serializer_associations.map do |assoc|
          if assoc.end_with?('s')
            "  has_many :#{assoc}"
          else
            "  has_one :#{assoc}"
          end
        end.join("\n")
      end

      def attribute_definitions
        return '' if @serializer_attributes.empty?

        @serializer_attributes.map { |attr| "  attribute :#{attr}" }.join("\n")
      end

      def namespace_path
        # Extract namespace from class_path if it exists
        class_path.empty? ? "" : class_path.join("/")
      end
    end
  end
end
