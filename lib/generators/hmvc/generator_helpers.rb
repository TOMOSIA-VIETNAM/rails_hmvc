# frozen_string_literal: true

require 'yaml'

module RailsHmvc
  module Generators
    module GeneratorHelpers
      def load_config
        config_path = File.join(destination_root, 'config/rails_hmvc.yml')
        return {} unless File.exist?(config_path)

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

        config || {}
      end

      def load_config_for_type(type = nil)
        config = load_config
        type ||= config['type'] || 'api'

        # Lấy cấu hình chung
        base_config = config.reject { |k, _| ['api', 'web'].include?(k) }

        # Lấy cấu hình theo type và merge với cấu hình chung
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


      # def versioned_namespace?
      #   class_path.first&.match?(/^v\d+$/)
      # end

      # def resource_namespace?
      #   class_path.size > 1
      # end

      # def controller_route_for(action, resource_name = nil)
      #   resource = resource_name || plural_name
      #   path = namespace_path.empty? ? resource : "#{namespace_path}/#{resource}"

      #   case action.to_s
      #   when 'index'
      #     "[GET] /#{path}"
      #   when 'show'
      #     "[GET] /#{path}/:id"
      #   when 'create'
      #     "[POST] /#{path}"
      #   when 'update'
      #     "[PUT] /#{path}/:id"
      #   when 'destroy'
      #     "[DELETE] /#{path}/:id"
      #   else
      #     "[#{action.to_s.upcase}] /#{path}"
      #   end
      # end
    end
  end
end
