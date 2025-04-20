# frozen_string_literal: true

require 'yaml'

module RailsHmvc
  module Generators
    module GeneratorHelpers
      def load_config
        config_path = File.join(destination_root, 'config/rails_hmvc.yml')
        return {} unless File.exist?(config_path)

        # Read file and handle manually if there is an error with aliases
        begin
          # Try reading with aliases: true (Rails 7+)
          yaml_content = File.read(config_path)
          config = YAML.safe_load(yaml_content, aliases: true) rescue nil

          # If error, try reading without aliases (Psych 4+)
          if config.nil?
            config = YAML.safe_load(yaml_content) rescue {}
          end
        rescue => e
          puts "Warning: Error loading rails_hmvc.yml: #{e.message}"
          return {}
        end

        config || {}
      end

      def load_config_for_type(type = nil)
        config = load_config
        type ||= config['type'] || 'api'

        base_config = config.reject { |k, _| ['api', 'web'].include?(k) }
        type_config = config[type.to_s] || {}
        base_config.merge(type_config)
      end

      def get_resource_config(resource_type)
        type = options[:type] || load_config['type'] || 'api'
        config = load_config_for_type(type)

        config[resource_type.to_s] || {}
      end

      def namespace_path
        class_path.join('/')
      end

      def namespace_name
        class_path.map(&:camelize).join('::')
      end

      def singular_human_name
        human_name.singularize
      end
    end
  end
end
