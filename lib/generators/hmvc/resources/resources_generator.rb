module RailsHmvc
  module Generators
    class ResourcesGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      class_option :version, type: :string, default: 'v1', desc: 'API version'
      class_option :type, type: :string, desc: 'Project type (api/web)'
      class_option :parent_controller, type: :string, desc: 'Parent controller class'
      class_option :parent_operation, type: :string, desc: 'Parent operation class'
      class_option :parent_form, type: :string, desc: 'Parent form class'
      class_option :parent_serializer, type: :string, desc: 'Parent serializer class'
      class_option :skip_routes, type: :boolean, default: false, desc: 'Skip routes generation'

      def initialize(*args)
        super
        @config = load_config
        set_defaults_from_config
      end

      def create_controller
        args = [
          "#{version}/#{plural_name}",
          "--actions=index,show,create,update,destroy",
          "--version=#{version}",
          "--parent=#{parent_controller_class}"
        ]

        Rails::Generators.invoke "rails_hmvc:controller", args, behavior: behavior
      end

      def create_operations
        %w[index show create update destroy].each do |action|
          args = [
            "#{version}/#{plural_name}/#{action}",
            "--version=#{version}",
            "--parent=#{parent_operation_class}"
          ]

          if action == 'index'
            args << "--steps=authorize,load_#{plural_name}"
          elsif action == 'show'
            args << "--steps=load_#{singular_name},authorize"
          elsif action == 'create'
            args << "--steps=authorize,validate_form,create_#{singular_name}"
          elsif action == 'update'
            args << "--steps=load_#{singular_name},authorize,validate_form,update_#{singular_name}"
          elsif action == 'destroy'
            args << "--steps=load_#{singular_name},authorize,destroy_#{singular_name}"
          end

          Rails::Generators.invoke "rails_hmvc:operation", args, behavior: behavior
        end
      end

      def create_forms
        %w[create update].each do |action|
          args = [
            "#{version}/#{plural_name}/#{action}",
            "--parent=#{parent_form_class}"
          ]

          Rails::Generators.invoke "rails_hmvc:form", args, behavior: behavior
        end
      end

      def create_serializer
        args = [
          "#{version}/#{singular_name}",
          "--version=#{version}",
          "--parent=#{parent_serializer_class}"
        ]

        Rails::Generators.invoke "rails_hmvc:serializer", args, behavior: behavior
      end

      def add_routes
        return if options[:skip_routes]

        route_config = <<-ROUTE
  resources :#{plural_name} do
    collection do
      get :index
    end
    member do
      get :show
      post :create
      put :update
      delete :destroy
    end
  end
ROUTE

        inject_into_file(
          'config/routes.rb',
          route_config,
          after: "scope module: :#{version}, path: '#{version}' do\n"
        )
      end

      private

      def version
        options[:version]
      end

      def load_config
        config_file = Rails.root.join('config', 'rails_hmvc.yml')
        return {} unless File.exist?(config_file)

        YAML.load_file(config_file)[Rails.env] || {}
      end

      def set_defaults_from_config
        options[:type] ||= @config['type']
        options[:parent_controller] ||= @config['parent_controller']
        options[:parent_operation] ||= @config['parent_operation']
        options[:parent_form] ||= @config['parent_form']
        options[:parent_serializer] ||= @config['parent_serializer']
      end

      def parent_controller_class
        "#{version.camelize}::#{version.upcase}Controller"
      end

      def parent_operation_class
        options[:parent_operation] || 'ApplicationOperation'
      end

      def parent_form_class
        options[:parent_form] || 'ApplicationForm'
      end

      def parent_serializer_class
        options[:parent_serializer] || 'ApplicationSerializer'
      end
    end
  end
end
