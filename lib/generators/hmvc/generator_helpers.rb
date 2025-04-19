# frozen_string_literal: true

require 'yaml'

module RailsHmvc
  module Generators
    module GeneratorHelpers
      def load_config
        config_path = File.join(destination_root, 'config/rails_hmvc.yml')
        return {} unless File.exist?(config_path)

        env = defined?(Rails.env) ? Rails.env : 'development'

        # Đọc file và xử lý thủ công nếu có lỗi với aliases
        begin
          # Thử đọc với aliases: true (Rails 7+)
          yaml_content = File.read(config_path)
          config = YAML.safe_load(yaml_content, aliases: true) rescue nil

          # Nếu lỗi, thử đọc không có aliases (Psych 4+)
          if config.nil?
            config = YAML.safe_load(yaml_content) rescue {}
          end
        rescue => e
          puts "Warning: Error loading rails_hmvc.yml: #{e.message}"
          return {}
        end

        config[env] || {}
      end

      def namespace_path
        class_path.join('/')
      end

      def namespace_name
        class_path.map(&:camelize).join('::')
      end

      def versioned_namespace?
        class_path.first&.match?(/^v\d+$/)
      end

      def resource_namespace?
        class_path.size > 1
      end
    end
  end
end
