# frozen_string_literal: true

require 'fileutils'
require 'active_support/inflector'

module RuboCop
  module Cop
    module RailsHmvc
      module Controllers
        # Ensures controller filenames and class names are pluralized.
        #
        # - app/controllers/v1/user_controller.rb  => OFFENSE, autocorrect to users_controller.rb
        # - class UserController < ApplicationController => OFFENSE, autocorrect to UsersController
        class PluralizedFilename < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Controller name must be pluralized (filename and class).'

          def on_new_investigation
            file_path = processed_source.file_path
            return unless controller_file?(file_path)

            basename = File.basename(file_path)
            resource = basename.sub('_controller.rb', '')
            plural_resource = ActiveSupport::Inflector.pluralize(resource)
            return if resource == plural_resource

            klass = processed_source.ast&.each_node(:class)&.first
            return unless klass&.loc&.name

            add_offense(klass.loc.name, message: MSG) do |corrector|
              autocorrect_filename_and_class(corrector, file_path, resource, plural_resource)
            end
          end

          def on_class(node)
            return unless controller_file?(processed_source.file_path)

            expected = expected_class_name_from_path(processed_source.file_path)
            current_name = node.loc.name&.source
            return if expected.nil? || current_name.nil?

            if current_name != expected
              add_offense(node.loc.name, message: MSG) do |corrector|
                corrector.replace(node.loc.name, expected)
              end
            end
          end

          private

          def controller_file?(file_path)
            return false unless file_path.match?(%r{/controllers/.*_controller\.rb$})

            # Skip base controllers to avoid mis-renames
            basename = File.basename(file_path)
            return false if %w[
              application_controller.rb
              api_controller.rb
              main_controller.rb
              base_controller.rb
            ].include?(basename)

            true
          end

          def expected_class_name_from_path(file_path)
            basename = File.basename(file_path)
            resource = basename.sub('_controller.rb', '')
            plural_resource = ActiveSupport::Inflector.pluralize(resource)
            "#{plural_resource.camelize}Controller"
          end

          def autocorrect_filename_and_class(corrector, file_path, resource, plural_resource)
            # Update class name in current buffer if present
            # We replace 'XxxController' with 'XxxsController' where appropriate.
            begin
              expected_class = "#{plural_resource.camelize}Controller"
              # Replace class name token in any class that ends with Controller
              processed_source.ast&.each_node(:class) do |class_node|
                current_name = class_node.loc.name&.source
                next unless current_name
                next unless current_name.end_with?('Controller')

                if current_name != expected_class
                  corrector.replace(class_node.loc.name, expected_class)
                end
              end
            rescue StandardError
              # best-effort only
            end

            # Attempt to rename file on disk as part of autocorrect
            begin
              dirname = File.dirname(file_path)
              new_path = File.join(dirname, "#{plural_resource}_controller.rb")
              return if new_path == file_path

              FileUtils.mv(file_path, new_path)
            rescue StandardError => e
              warn("[RailsHmvc::Controllers::PluralizedFilename] Failed to rename #{file_path}: #{e.message}")
            end
          end
        end
      end
    end
  end
end
