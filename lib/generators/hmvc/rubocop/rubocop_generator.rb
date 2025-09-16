# frozen_string_literal: true

require 'rails/generators'
require_relative '../generator_helpers'

module RailsHmvc
  module Generators
    class RubocopGenerator < Rails::Generators::Base
      include GeneratorHelpers

      source_root File.expand_path('templates', __dir__)

      class_option :force, type: :boolean, default: false, desc: 'Force overwrite existing .rubocop.yml'

      def create_rubocop_config
        if File.exist?('.rubocop.yml') && !options[:force]
          say('⚠️  .rubocop.yml already exists. Use --force to overwrite.', :yellow)
          say('💡 You can manually copy configuration from examples/.rubocop.yml.example', :blue)
          return
        end

        copy_file_from_example
        create_rubocop_script
        create_rubocop_todo_if_needed
        show_setup_instructions
      end

      private

      def copy_file_from_example
        example_path = File.expand_path('../../../examples/.rubocop.yml.example', __dir__)

        if File.exist?(example_path)
          copy_file(example_path, '.rubocop.yml')
          say('✅ Created .rubocop.yml with Rails HMVC configuration', :green)
        else
          create_basic_config
        end
      end

      def create_basic_config
        create_file('.rubocop.yml', basic_rubocop_config)
        say('✅ Created basic .rubocop.yml with Rails HMVC cops', :green)
      end

      def create_rubocop_script
        empty_directory('bin') unless File.directory?('bin')

        create_file('bin/rubocop-hmvc', rubocop_script_content)
        chmod('bin/rubocop-hmvc', 0o755)
        say('✅ Created bin/rubocop-hmvc shortcut script', :green)
      end

      def create_rubocop_todo_if_needed
        return unless File.exist?('.rubocop.yml')

        say('🔍 Analyzing existing code for HMVC violations...', :blue)

        # Run rubocop to generate .rubocop_todo.yml
        system('bundle exec rubocop --auto-gen-config --only RailsHmvc 2>/dev/null')

        return unless File.exist?('.rubocop_todo.yml')

        say('📝 Generated .rubocop_todo.yml with existing violations', :yellow)
        say('💡 Fix violations gradually and remove them from .rubocop_todo.yml', :blue)
      end

      def show_setup_instructions
        say("\n🎉 Rails HMVC RuboCop setup complete!", :green)
        say("\n📋 Next steps:", :blue)
        say('1. Install required gems:', :blue)
        say('   bundle add rubocop-rails rubocop-rspec --group development', :cyan)
        say('2. Update Ruby version in .rubocop.yml if needed:', :blue)
        say('   TargetRubyVersion: 3.2  # Match your Ruby version', :cyan)
        say('3. Run RuboCop to check your code:', :blue)
        say('   bundle exec rubocop', :cyan)
        say('4. Run only HMVC cops:', :blue)
        say('   bundle exec rubocop --only RailsHmvc/Operations,RailsHmvc/Forms,RailsHmvc/Controllers,RailsHmvc/Models', :cyan)
        say('   OR use shortcut: ./bin/rubocop-hmvc', :cyan)
        say('5. Auto-fix simple violations:', :blue)
        say('   ./bin/rubocop-hmvc --safe-auto-correct', :cyan)
        say("\n📖 See RUBOCOP_HMVC.md for detailed documentation", :blue)
      end

      def basic_rubocop_config
        <<~YAML
          # Rails HMVC RuboCop Configuration

          require:
            - rails_hmvc

          plugins:
            - rubocop-rails
            - rubocop-rspec

          AllCops:
            TargetRubyVersion: #{RUBY_VERSION.split(".")[0..1].join(".")}
            NewCops: enable
            Exclude:
              - 'vendor/**/*'
              - 'bin/**/*'
              - 'db/**/*'
              - 'tmp/**/*'
              - 'log/**/*'

          # Rails HMVC Custom Cops
          RailsHmvc/Operations/CallMethod:
            Enabled: true
            Include:
              - 'app/operations/**/*_operation.rb'

          RailsHmvc/Operations/StepMethods:
            Enabled: true
            Include:
              - 'app/operations/**/*_operation.rb'

          RailsHmvc/Forms/ValidationOnly:
            Enabled: true
            Include:
              - 'app/forms/**/*_form.rb'

          RailsHmvc/Controllers/NoBusinessLogic:
            Enabled: true
            Include:
              - 'app/controllers/**/*_controller.rb'

          RailsHmvc/Controllers/DelegateToOperations:
            Enabled: true
            Include:
              - 'app/controllers/**/*_controller.rb'

          # See examples/.rubocop.yml.example for more comprehensive configuration
        YAML
      end

      def rubocop_script_content
        <<~SCRIPT
          #!/usr/bin/env bash

          # Rails HMVC RuboCop Runner
          # Runs all HMVC custom cops

          # All HMVC departments
          HMVC_DEPARTMENTS="RailsHmvc/Operations,RailsHmvc/Forms,RailsHmvc/Controllers,RailsHmvc/Models"

          echo "🔍 Running Rails HMVC RuboCop cops..."
          echo "Departments: $HMVC_DEPARTMENTS"
          echo ""

          # Run with all arguments passed through
          bundle exec rubocop --only "$HMVC_DEPARTMENTS" "$@"
        SCRIPT
      end
    end
  end
end
