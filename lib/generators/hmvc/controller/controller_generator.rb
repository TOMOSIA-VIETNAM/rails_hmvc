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

      def initialize(*args)
        super
        @config = load_config_for_type(options[:type])
        @controllers_config = @config["controllers"]
        @operations_config = @config["operations"]
        @forms_config = @config["forms"]
        @views_config = @config["views"] || {}
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
        return "head :no_content" if skip_operation?

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
          "    )"
        else
          "head :no_content"
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
    end
  end
end
