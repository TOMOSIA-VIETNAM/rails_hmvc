require "rails/generators"
require "rails/generators/named_base"
require_relative "../generator_helpers"

module RailsHmvc
  module Generators
    class ControllerGenerator < Rails::Generators::NamedBase
      include GeneratorHelpers

      source_root File.expand_path("templates", __dir__)

      class_option :type, type: :string, desc: "Project type (api/web)"

      # Controller options
      class_option :skip_controller, type: :boolean, default: false, desc: "Skip generating controller"
      class_option :parent, type: :string, desc: "Parent controller class"
      class_option :actions, type: :string, desc: "List of controller actions to include"

      # Operation options
      class_option :skip_operation, type: :boolean, default: false, desc: "Skip associating with operations"
      class_option :parent_operation, type: :string, desc: "Parent operation class"
      class_option :steps, type: :string, desc: "List of operation steps to include"

      # Form options
      class_option :skip_form, type: :boolean, default: false, desc: "Skip associating with forms"
      class_option :parent_form, type: :string, desc: "Parent form class"
      class_option :attributes, type: :string, desc: "List of form attributes in the format: name:type"

      # Views options
      class_option :views, type: :boolean, default: false, desc: "Generate views for the controller"
      class_option :skip_views, type: :boolean, default: false, desc: "Skip generating views"

      # Routes options
      class_option :routes, type: :boolean, default: false, desc: "Generate routes for the controller"
      class_option :skip_routes, type: :boolean, default: false, desc: "Skip generating routes"
      class_option :resource_routes, type: :boolean, default: true, desc: "Use resource routes (true) or individual routes (false)"

      # Serializer options
      class_option :skip_serializer, type: :boolean, default: false, desc: 'Skip associating with serializers'
      class_option :parent_serializer, type: :string, desc: 'Parent serializer class'
      class_option :attributes, type: :string, desc: 'List of serializer attributes in the format: name'

      def initialize(*args)
        super
        @config = load_config_for_type(options[:type])
        @controllers_config = @config["controllers"]
        @operations_config = @config["operations"]
        @forms_config = @config["forms"]
        @views_config = @config["views"] || {}
        @routes_config = @config["routes"] || {}
        @serializers_config = @config["serializers"] || {}
        set_defaults_from_config
      end

      def create_controller
        return if skip_controller?

        template("controller.rb", "app/controllers/#{controller_path}.rb")
      end

      def create_operations
        return if skip_operation?

        actions.each do |action|
          Rails::Generators.invoke("rails_hmvc:operation", [
                                     "#{namespace_path}/#{plural_name}/#{action}",
                                     "--type=#{@options[:type]}",
                                     "--parent=#{@options[:parent_operation]}",
                                     "--steps=#{@options[:steps]}"
                                   ], destination_root: destination_root)
        end
      end

      def create_forms
        return if skip_form?

        form_actions = @forms_config["actions"]
        skip_actions = @forms_config["skip_actions"] || []

        form_actions.each do |action|
          next if skip_actions.include?(action)
          next unless actions.include?(action)

          Rails::Generators.invoke("rails_hmvc:form", [
                                     "#{namespace_path}/#{plural_name}/#{action}",
                                     "--type=#{@options[:type]}",
                                     "--parent=#{@options[:parent_form]}",
                                     "--attributes=#{@options[:attributes]}"
                                   ], destination_root: destination_root)
        end
      end

      def create_serializers
        return if skip_serializer?

        serializer_actions = @serializers_config['actions'] || []
        skip_actions = @serializers_config['skip_actions'] || []

        return if serializer_actions.empty?

        serializer_actions.each do |action|
          next if skip_actions.include?(action)
          next unless actions.include?(action)

          Rails::Generators.invoke('rails_hmvc:serializer', [
                                     "#{namespace_path}/#{plural_name}/#{action}",
                                     "--type=#{@options[:type]}",
                                     "--parent=#{@options[:parent_serializer]}",
                                     "--attributes=#{@options[:attributes]}"
                                   ], destination_root: destination_root)
        end

        say "Serializers created for #{plural_name}", :green
      end

      def create_views
        return if skip_views?

        views_path = "app/views/#{namespace_path}/#{plural_name}"
        empty_directory views_path

        view_actions = @views_config["actions"] || %w[index show new edit]
        view_partials = @views_config["partials"] || ["form"]

        # Create view templates for actions that exist in controller
        view_actions.each do |action|
          next unless actions.include?(action)

          create_view_template(action, views_path)
        end

        # Create partials
        view_partials.each do |partial|
          create_view_partial(partial, views_path)
        end

        say "Views created at #{views_path}/", :green
      end

      def create_routes
        return if skip_routes?

        routes_path = "config/routes.rb"
        unless File.exist?(routes_path)
          say "⚠️  Routes file not found at #{routes_path}", :yellow
          return
        end

        # Generate routes based on configuration
        routes_content = generate_routes_content

        # Insert routes into routes.rb file
        insert_routes_into_file(routes_path, routes_content)

        say "✅ Routes added to #{routes_path}", :green
        say "📝 Added: #{routes_content.strip}", :blue
      end

      private

      def set_defaults_from_config
        @options = options.dup
        @options[:type] ||= @config["type"]

        # Controller options
        @options[:parent]  ||= @controllers_config["parent"]
        @options[:actions] ||= @controllers_config["actions"]

        # Operation options
        @options[:parent_operation] ||= @operations_config["parent"]
        @options[:steps]            ||= @operations_config["steps"]

        # Form options
        @options[:parent_form] ||= @forms_config["parent"]

        # Serializer options
        @options[:parent_serializer] ||= @serializers_config["parent"]
      end

      def parent_controller_class
        @options[:parent] || "#{namespace_name.split("::").first}Controller"
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

      def namespace_path
        # Extract namespace from class_path if it exists
        class_path.empty? ? "" : class_path.join("/")
      end

      def actions
        return @options[:actions].split(",") if @options[:actions].is_a?(String)

        @options[:actions]
      end

      def skip_controller?
        @options[:skip_controller]
      end

      def skip_operation?
        @options[:skip_operation]
      end

      def skip_form?
        @options[:skip_form]
      end

      def skip_views?
        return true if @options[:skip_views]
        return false if @options[:views]

        # Auto-generate views for web type unless explicitly skipped
        !(@options[:type] == "web" && @views_config["generate"] != false)
      end

      def skip_routes?
        return true if @options[:skip_routes]
        return false if @options[:routes]

        # Check config-based auto-generation
        return false if @routes_config["generate"]

        true
      end

      def skip_serializer?
        @options[:skip_serializer]
      end

      def operation_class_for(action)
        "#{resource_class}::#{action.camelize}Operation"
      end

      def http_method_for(action)
        case action
        when "index", "show", "new", "edit" then "GET"
        when "create" then "POST"
        when "update" then "PUT"
        when "destroy" then "DELETE"
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
        if @options[:type] == "api"
          render_api_response(action)
        else
          render_web_response(action)
        end
      end

      def render_api_response(action)
        return 'head :no_content' if skip_operation?

        case action
        when "index"
          "render_collection(\n" \
          "      collection: [],\n" \
          "      serializer: '',\n" \
          "      meta: pagination_meta([])\n" \
          "    )"
        when "show", "create", "update"
          status = action == "create" ? ":created" : ":ok"
          "render_resource(\n" \
          "      resource: nil,\n" \
          "      serializer: '',\n" \
          "      status: #{status}\n" \
          '    )'
        else
          'head :no_content'
        end
      end

      def render_web_response(action)
        case action
        when "index"
          "render :index"
        when "show"
          "render :show"
        when "new"
          "render :new"
        when "edit"
          "render :edit"
        when "create"
          return "render :new" if skip_operation?

          "if operator.success?\n" \
          "      redirect_to '#', notice: '#{singular_human_name_helper} was successfully created.'\n" \
          "    else\n" \
          "      render :new, alert: '#{singular_human_name_helper} could not be created.'\n" \
          "    end"
        when "update"
          return "render :edit" if skip_operation?

          "if operator.success?\n" \
          "      redirect_to '#', notice: '#{singular_human_name_helper} was successfully updated.'\n" \
          "    else\n" \
          "      render :edit, alert: '#{singular_human_name_helper} could not be updated.'\n" \
          "    end"
        when "destroy"
          return "head :no_content" if skip_operation?

          "if operator.success?\n" \
          "      redirect_to '#'\n" \
          "    else\n" \
          "      render :index, alert: '#{singular_human_name_helper} could not be destroyed.'\n" \
          "    end"
        else
          "render :#{action}"
        end
      end

      def create_view_template(action, views_path)
        # Set template variables for ERB processing
        @resource_name = plural_name
        @singular_name = singular_name
        @plural_name = plural_name
        @singular_human_name = singular_human_name_helper
        @plural_human_name = plural_human_name_helper
        @namespace_path = namespace_path
        @route_prefix = route_prefix

        template "views/#{action}.html.erb.tt", "#{views_path}/#{action}.html.erb"
      end

      def create_view_partial(partial, views_path)
        # Set template variables for ERB processing
        @resource_name = plural_name
        @singular_name = singular_name
        @plural_name = plural_name
        @singular_human_name = singular_human_name_helper
        @plural_human_name = plural_human_name_helper
        @namespace_path = namespace_path
        @route_prefix = route_prefix

        template "views/_#{partial}.html.erb.tt", "#{views_path}/_#{partial}.html.erb"
      end

      def route_prefix
        if namespace_path.present?
          "#{namespace_path.gsub("/", "_")}_#{plural_name}"
        else
          plural_name
        end
      end

      def plural_human_name_helper
        plural_name.humanize
      end

      def singular_human_name_helper
        singular_name.humanize
      end

      # Routes generation methods
      def generate_routes_content
        if use_resource_routes?
          generate_resource_routes
        else
          generate_individual_routes
        end
      end

      def use_resource_routes?
        return @options[:resource_routes] if @options.key?(:resource_routes)
        return @routes_config["resource_routes"] if @routes_config.key?("resource_routes")

        # Default: use resource routes for standard CRUD actions
        standard_actions = %w[index show new edit create update destroy]
        (actions & standard_actions).size >= 3
      end

      def generate_resource_routes
        resource_name = plural_name

        # Handle namespaced routes
        if namespace_path.present?
          indent = "  "
          namespace_parts = namespace_path.split("/")

          # Create nested namespace structure
          route_start = namespace_parts.map { |ns| "#{indent}namespace :#{ns} do" }.join("\n")
          route_content = "#{indent}  resources :#{resource_name}#{route_options}"
          route_end = namespace_parts.map { indent + "end" }.reverse.join("\n")

          "#{route_start}\n#{route_content}\n#{route_end}"
        else
          "  resources :#{resource_name}#{route_options}"
        end
      end

      def generate_individual_routes
        routes = []
        indent = namespace_indent

        actions.each do |action|
          routes << generate_individual_route(action, indent)
        end

        if namespace_path.present?
          wrap_with_namespaces(routes.join("\n"))
        else
          routes.join("\n")
        end
      end

      def route_options
        # Add only: option if not all standard actions are present
        standard_actions = %w[index show new edit create update destroy]
        used_actions = actions & standard_actions

        return "" if used_actions.sort == standard_actions.sort

        ", only: #{used_actions.inspect}"
      end

      def generate_individual_route(action, indent)
        case action
        when "index"
          "#{indent}get '#{plural_name}', to: '#{controller_route_path}#index'"
        when "show"
          "#{indent}get '#{plural_name}/:id', to: '#{controller_route_path}#show'"
        when "new"
          "#{indent}get '#{plural_name}/new', to: '#{controller_route_path}#new'"
        when "edit"
          "#{indent}get '#{plural_name}/:id/edit', to: '#{controller_route_path}#edit'"
        when "create"
          "#{indent}post '#{plural_name}', to: '#{controller_route_path}#create'"
        when "update"
          "#{indent}patch '#{plural_name}/:id', to: '#{controller_route_path}#update'\n" \
          "#{indent}put '#{plural_name}/:id', to: '#{controller_route_path}#update'"
        when "destroy"
          "#{indent}delete '#{plural_name}/:id', to: '#{controller_route_path}#destroy'"
        else
          # Custom action - assume it's a member action
          "#{indent}get '#{plural_name}/:id/#{action}', to: '#{controller_route_path}##{action}'"
        end
      end

      def controller_route_path
        if namespace_path.present?
          "#{namespace_path}/#{plural_name}"
        else
          plural_name
        end
      end

      def namespace_indent
        if namespace_path.present?
          "  " + ("  " * namespace_path.split("/").size)
        else
          "  "
        end
      end

      def wrap_with_namespaces(content)
        return content if namespace_path.blank?

        indent = "  "
        namespace_parts = namespace_path.split("/")

        # Create nested namespace structure
        route_start = namespace_parts.map { |ns| "#{indent}namespace :#{ns} do" }.join("\n")
        route_end = namespace_parts.map { indent + "end" }.reverse.join("\n")

        "#{route_start}\n#{content}\n#{route_end}"
      end

      def insert_routes_into_file(routes_path, routes_content)
        # Read current routes file
        routes_file_content = File.read(routes_path)

        # Find insertion point - after the first "Rails.application.routes.draw do"
        insertion_point = routes_file_content.index("Rails.application.routes.draw do")

        if insertion_point.nil?
          say "⚠️  Could not find 'Rails.application.routes.draw do' in #{routes_path}", :yellow
          return
        end

        # Find end of the line
        line_end = routes_file_content.index("\n", insertion_point)
        insertion_index = line_end + 1

        # Check if routes already exist
        if routes_file_content.include?(routes_content.strip)
          say "ℹ️  Routes already exist, skipping", :blue
          return
        end

        # Insert routes content
        new_content = routes_file_content[0...insertion_index] +
                     "\n" + routes_content + "\n" +
                     routes_file_content[insertion_index..-1]

        # Write back to file
        File.write(routes_path, new_content)
      end
    end
  end
end
