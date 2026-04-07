# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/named_base'
require_relative '../generator_helpers'

module RailsHmvc
  module Generators
    class MultiGenerator < Rails::Generators::Base
      include GeneratorHelpers

      source_root File.expand_path('templates', __dir__)

      # Arguments in order: generators_list, resource_name
      argument :generators_list, type: :string, desc: 'Comma-separated list of generators to run (e.g., operation,form,serializer)'
      argument :resource_name, type: :string, desc: 'Name of the resource to generate'

      class_option :type, type: :string, desc: 'Project type (api/web)'

      # Universal options (can be used by any generator)
      class_option :actions, type: :string, desc: 'List of actions to generate'
      class_option :attributes, type: :string, desc: 'List of attributes'
      class_option :steps, type: :string, desc: 'List of operation steps'

      # Parent class options
      class_option :parent_operation, type: :string, desc: 'Parent operation class'
      class_option :parent_form, type: :string, desc: 'Parent form class'
      class_option :parent_serializer, type: :string, desc: 'Parent serializer class'
      class_option :parent, type: :string, desc: 'Parent controller class'

      # Skip options
      class_option :skip_operation, type: :boolean, default: false, desc: 'Skip operations'
      class_option :skip_form, type: :boolean, default: false, desc: 'Skip forms'
      class_option :skip_serializer, type: :boolean, default: false, desc: 'Skip serializers'
      class_option :skip_controller, type: :boolean, default: false, desc: 'Skip controller'
      class_option :skip_views, type: :boolean, default: false, desc: 'Skip views'
      class_option :skip_routes, type: :boolean, default: false, desc: 'Skip routes'

      # Route-specific options
      class_option :routes, type: :boolean, default: false, desc: 'Generate routes'
      class_option :views, type: :boolean, default: false, desc: 'Generate views'
      class_option :resource_routes, type: :boolean, default: true, desc: 'Use resource routes'

      def initialize(*args)
        super
        @generators_to_run = parse_generators_list
        validate_generators_list

        # Parse resource name to extract class_path and file_name
        @class_path = extract_class_path
        @file_name = extract_file_name
        @singular_name = @file_name

        # Load config
        explicit_type = options[:type]
        if explicit_type
          @config = load_config_for_type(explicit_type)
        else
          full_config = load_config
          default_type = full_config["type"] || "api"
          @config = load_config_for_type(default_type)
        end
      end

      def run_generators
        if @generators_to_run.empty?
          show_usage_help
          exit 1
        end

        say "🚀 Running #{@generators_to_run.size} generators for #{singular_name}:", :blue
        @generators_to_run.each { |gen| say "  - #{gen}", :cyan }
        say ""

        results = {}

        @generators_to_run.each do |generator_name|
          if should_skip_generator?(generator_name)
            say "⏭️  Skipping #{generator_name} (--skip_#{generator_name})", :yellow
            next
          end

          say "🔄 Generating #{generator_name}...", :green

          begin
            invoke_generator(generator_name)
            results[generator_name] = :success
            say "✅ #{generator_name.capitalize} completed", :green
          rescue => e
            results[generator_name] = :failed
            say "❌ #{generator_name.capitalize} failed: #{e.message}", :red
          end
        end

        show_summary(results)
      end

      private

      def parse_generators_list
        return [] if generators_list.blank?

        generators_list.split(',').map(&:strip).map(&:downcase)
      end

      def validate_generators_list
        allowed_generators = %w[controller operation form serializer]
        invalid_generators = @generators_to_run - allowed_generators

        unless invalid_generators.empty?
          say "❌ Invalid generators: #{invalid_generators.join(', ')}", :red
          say "Available generators: #{allowed_generators.join(', ')}", :blue
          exit 1
        end
      end

      def should_skip_generator?(generator_name)
        skip_option = "skip_#{generator_name}".to_sym
        options[skip_option] == true
      end

      def invoke_generator(generator_name)
        case generator_name
        when 'controller'
          invoke_controller_generator
        when 'operation'
          invoke_operation_generator
        when 'form'
          invoke_form_generator
        when 'serializer'
          invoke_serializer_generator
        else
          raise "Unknown generator: #{generator_name}"
        end
      end

      def invoke_controller_generator
        controller_options = build_controller_options
        Rails::Generators.invoke("rails_hmvc:controller", [
                                   full_resource_path,
                                   *controller_options
                                 ], destination_root: destination_root)
      end

      def invoke_operation_generator
        return unless has_actions?

        operation_options = build_operation_options
        Rails::Generators.invoke("rails_hmvc:operation", [
                                   full_resource_path,
                                   *operation_options
                                 ], destination_root: destination_root)
      end

      def invoke_form_generator
        return unless has_actions?

        form_options = build_form_options
        Rails::Generators.invoke("rails_hmvc:form", [
                                   full_resource_path,
                                   *form_options
                                 ], destination_root: destination_root)
      end

      def invoke_serializer_generator
        serializer_options = build_serializer_options
        Rails::Generators.invoke("rails_hmvc:serializer", [
                                   full_resource_path,
                                   *serializer_options
                                 ], destination_root: destination_root)
      end

      def build_controller_options
        opts = []
        opts << "--type=#{options[:type]}" if options[:type]
        opts << "--actions=#{options[:actions]}" if options[:actions]
        opts << "--parent=#{options[:parent]}" if options[:parent]
        opts << "--attributes=#{options[:attributes]}" if options[:attributes]
        opts << "--steps=#{options[:steps]}" if options[:steps]
        opts << "--parent_operation=#{options[:parent_operation]}" if options[:parent_operation]
        opts << "--parent_form=#{options[:parent_form]}" if options[:parent_form]
        opts << "--parent_serializer=#{options[:parent_serializer]}" if options[:parent_serializer]
        opts << "--routes" if options[:routes]
        opts << "--views" if options[:views]
        opts << "--skip_views" if options[:skip_views]
        opts << "--skip_routes" if options[:skip_routes]
        opts << "--no-resource-routes" unless options[:resource_routes]
        opts
      end

      def build_operation_options
        opts = []
        opts << "--type=#{options[:type]}" if options[:type]
        opts << "--actions=#{options[:actions]}" if options[:actions]
        opts << "--parent=#{options[:parent_operation]}" if options[:parent_operation]
        opts << "--steps=#{options[:steps]}" if options[:steps]
        opts
      end

      def build_form_options
        opts = []
        opts << "--type=#{options[:type]}" if options[:type]
        opts << "--actions=#{options[:actions]}" if options[:actions]
        opts << "--parent=#{options[:parent_form]}" if options[:parent_form]
        opts << "--attributes=#{options[:attributes]}" if options[:attributes]
        opts
      end

      def build_serializer_options
        opts = []
        opts << "--type=#{options[:type]}" if options[:type]
        opts << "--actions=#{options[:actions]}" if options[:actions]
        opts << "--parent=#{options[:parent_serializer]}" if options[:parent_serializer]
        opts << "--attributes=#{options[:attributes]}" if options[:attributes]
        opts
      end

      def has_actions?
        options[:actions].present?
      end

      def namespace_path
        class_path.empty? ? "" : class_path.join("/")
      end

      def full_resource_path
        if class_path.empty?
          singular_name
        else
          "#{class_path.join('/')}/#{singular_name}"
        end
      end

      # NamedBase emulation methods
      def extract_class_path
        parts = resource_name.split('/')
        parts.size > 1 ? parts[0..-2] : []
      end

      def extract_file_name
        resource_name.split('/').last.underscore
      end

      def class_path
        @class_path
      end

      def file_name
        @file_name
      end

      def singular_name
        @singular_name
      end

      def plural_name
        @singular_name.pluralize
      end

      def class_name
        @singular_name.camelize
      end

      def show_usage_help
        say "❌ No generators specified!", :red
        say ""
        say "Usage examples:", :blue
        say "  rails g rails_hmvc:multi operation,form #{resource_name} --actions=create,update", :cyan
        say "  rails g rails_hmvc:multi controller,operation,form #{resource_name} --type=web", :cyan
        say "  rails g rails_hmvc:multi operation,serializer #{resource_name} --actions=index,show", :cyan
        say ""
        say "Available generators: controller, operation, form, serializer", :blue
        say "Options: --actions, --type, --attributes, --steps, --skip_*, etc.", :blue
      end

      def show_summary(results)
        say ""
        say "📊 Generation Summary:", :blue
        say "─" * 50, :blue

        results.each do |generator, status|
          icon = status == :success ? "✅" : "❌"
          color = status == :success ? :green : :red
          say "#{icon} #{generator.capitalize.ljust(12)} #{status}", color
        end

        success_count = results.values.count(:success)
        total_count = results.size

        say "─" * 50, :blue
        say "🎯 #{success_count}/#{total_count} generators completed successfully",
            success_count == total_count ? :green : :yellow
      end
    end
  end
end
