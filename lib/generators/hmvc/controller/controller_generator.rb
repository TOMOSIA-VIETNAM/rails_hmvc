require 'rails/generators'
require 'rails/generators/named_base'
require_relative '../generator_helpers'

module RailsHmvc
  module Generators
    class ControllerGenerator < Rails::Generators::NamedBase
      include GeneratorHelpers

      source_root File.expand_path('templates', __dir__)

      class_option :actions, type: :string, desc: 'List of controller actions to include'
      class_option :parent, type: :string, desc: 'Parent controller class'
      class_option :type, type: :string, desc: 'Project type (api/web)'
      class_option :skip_operations, type: :boolean, default: false, desc: 'Skip associating with operations'
      class_option :skip_forms, type: :boolean, default: false, desc: 'Skip associating with forms'

      def initialize(*args)
        super
        @config = load_config_for_type(options[:type])
        @resource_config = get_resource_config('controllers')
        set_defaults_from_config
      end

      def create_controller_file
        template(
          'controller.rb',
          "app/controllers/#{controller_path}.rb"
        )
      end

      private

      def set_defaults_from_config
        @options = options.dup

        @options[:parent] ||= @config['parent_controller']
        @options[:actions] ||= @resource_config['actions'] || %w[index show create update destroy]
      end

      def parent_controller_class
        @options[:parent] || "#{namespace_name.split('::').first}Controller"
      end

      def controller_path
        "#{namespace_path}/#{plural_name}_controller"
      end

      def controller_class_name
        "#{resource_class}Controller"
      end

      def resource_class
        class_name
      end

      def actions
        return @options[:actions].split(',') if @options[:actions].is_a?(String)

        @options[:actions]
      end

      def skip_operations?
        @options[:skip_operations]
      end

      def skip_forms?
        @options[:skip_forms]
      end

      def operation_class_for(action)
        "#{resource_class}::#{action.camelize}Operation"
      end

      def form_class_for(action)
        "#{resource_class}::#{action.camelize}Form"
      end

      def http_method_for(action)
        case action
        when 'index', 'show', 'new', 'edit' then 'GET'
        when 'create' then 'POST'
        when 'update' then 'PUT'
        when 'destroy' then 'DELETE'
        end
      end

      def route_path_for(action)
        base_path = "/#{namespace_path}/#{plural_name}"
        needs_id = %w[show update destroy edit].include?(action)
        needs_id ? "#{base_path}/:id" : base_path
      end

      def action_comment_for(action)
        "#{http_method_for(action)} #{route_path_for(action)}"
      end

      def render_for_action(action)
        if @options[:type] == 'api'
          render_api_response(action)
        else
          render_web_response(action)
        end
      end

      def render_api_response(action)
        return "head :no_content" if skip_operations?

        case action
        when 'index'
          "render_collection(\n" \
          "      collection: [],\n" \
          "      serializer: '',\n" \
          "      meta: pagination_meta([])\n" \
          "    )"
        when 'show', 'create', 'update'
          status = action == 'create' ? ':created' : ':ok'
          "render_resource(\n" \
          "      resource: nil,\n" \
          "      serializer: '',\n" \
          "      status: #{status}\n" \
          "    )"
        else
          "head :no_content"
        end
      end

      def render_web_response(action)
        case action
        when 'index'
          "render :index"
        when 'show'
          "render :show"
        when 'new'
          "render :new"
        when 'edit'
          "render :edit"
        when 'create'
          return "head :no_content" if skip_operations?

          "if operator.success?\n" \
          "      redirect_to '#', notice: '#{singular_human_name} was successfully created.'\n" \
          "    else\n" \
          "      render :new, alert: '#{human_name} could not be created.'\n" \
          "    end"
        when 'update'
          return "head :no_content" if skip_operations?

          "if operator.success?\n" \
          "      redirect_to '#', notice: '#{singular_human_name} was successfully updated.'\n" \
          "    else\n" \
          "      render :edit, alert: '#{singular_human_name} could not be updated.'\n" \
          "    end"
        when 'destroy'
          return "head :no_content" if skip_operations?

          "if operator.success?\n" \
          "      redirect_to '#'\n" \
          "    else\n" \
          "      render :index, alert: '#{human_name} could not be destroyed.'\n" \
          "    end"
        else
          "render :#{action}"
        end
      end
    end
  end
end
