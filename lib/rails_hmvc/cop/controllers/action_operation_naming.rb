# frozen_string_literal: true

require 'fileutils'
require 'active_support/inflector'

module RuboCop
  module Cop
    module RailsHmvc
      module Controllers
        # Ensures that controllers reference Operation/Form classes that match the action name
        # and auto-corrects class names, file names, and call sites.
        #
        # Example: in #create, should use Xxx::CreateOperation and Xxx::CreateForm
        class ActionOperationNaming < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use action-based names (Create/Update/Destroy/Show/Index/New/Edit) for Operation/Form.'

          ACTION_CLASS = {
            create: 'Create',
            update: 'Update',
            destroy: 'Destroy',
            show: 'Show',
            index: 'Index',
            new: 'New',
            edit: 'Edit'
          }.freeze

          def_node_matcher :controller_class?, <<~PATTERN
            (class
              (const _ !nil)
              (const ...)
              ...)
          PATTERN

          def_node_search :operation_const_nodes, <<~PATTERN
            (const (const (const _ _) _) $_)
          PATTERN

          def_node_search :form_const_nodes, <<~PATTERN
            (const (const (const _ _) _) $_)
          PATTERN

          def on_class(node)
            return unless controller_class?(node)
            return unless controller_file?(processed_source.file_path)

            class_body = node.body
            return unless class_body

            actions = extract_actions(class_body)
            actions.each { |action| check_action(action) }
          end

          private

          def controller_file?(file_path)
            file_path.match?(%r{/controllers/.*_controller\.rb$})
          end

          def extract_actions(class_body)
            nodes = class_body.type == :begin ? class_body.children : [class_body]
            nodes.select { |n| n.type == :def }
          end

          def check_action(action_node)
            action_name = action_node.method_name
            expected_prefix = ACTION_CLASS[action_name]
            return unless expected_prefix

            # Check operation references
            operation_refs = find_const_refs(action_node.body, /Operation\z/)
            operation_refs.each do |const_node|
              correct_action_reference(action_node, const_node, expected_prefix, 'Operation')
            end

            # Check form references
            form_refs = find_const_refs(action_node.body, /Form\z/)
            form_refs.each do |const_node|
              correct_action_reference(action_node, const_node, expected_prefix, 'Form')
            end
          end

          def find_const_refs(node, suffix_regex)
            return [] unless node
            nodes = []
            node.each_descendant(:const) do |c|
              full_name = const_full_name(c)
              next unless full_name
              nodes << c if full_name.match?(suffix_regex)
            end
            nodes
          end

          def const_full_name(const_node)
            names = []
            current = const_node
            while current&.type == :const
              names.unshift(current.children[1].to_s)
              current = current.children[0]
            end
            return nil if names.empty?
            names.join('::')
          end

          def correct_action_reference(action_node, const_node, expected_prefix, kind)
            full_name = const_full_name(const_node)
            return unless full_name

            parts = full_name.split('::')
            return if parts.empty?

            leaf = parts.last # e.g., HelloOperation
            resource_namespace = parts[0..-2] # e.g., Api, V1, User

            # If leaf already matches expected_prefix, skip
            return if leaf.start_with?(expected_prefix)

            expected_leaf = "#{expected_prefix}#{kind}"
            expected_full = (resource_namespace + [expected_leaf]).join('::')

            add_offense(const_node, message: MSG) do |corrector|
              # Replace constant reference in source
              corrector.replace(const_node.source_range, expected_full)
            end

            # Try to rename file on disk. We infer path from namespace and controller path.
            rename_target_file(kind, expected_prefix)
          end

          def rename_target_file(kind, expected_prefix)
            # Infer resource folder from controller path
            controller_path = processed_source.file_path
            controller_dir = File.dirname(controller_path)

            # resource folder is singular of controller folder name
            controller_folder = File.basename(controller_dir)
            resource = ActiveSupport::Inflector.singularize(controller_folder)

            base_dir = kind == 'Operation' ? 'app/operations' : 'app/forms'

            # Compose expected and unknown old pattern; we will rename any *_operation/form.rb that does not match
            begin
              # Find all files under resource dir
              Dir.glob(File.join(base_dir, '**', resource, "*_#{kind.downcase}.rb")).each do |path|
                filename = File.basename(path)
                # Skip if already correct
                next if filename.start_with?(expected_prefix.downcase)

                old_stem = filename.sub("_#{kind.downcase}.rb", '')
                old_class = "#{old_stem.camelize}#{kind}"

                new_name = "#{expected_prefix.downcase}_#{kind.downcase}.rb"
                new_path = File.join(File.dirname(path), new_name)
                next if new_path == path

                # Rename file on disk
                FileUtils.mv(path, new_path)

                # Update class name inside renamed file
                begin
                  content = File.read(new_path)
                  expected_class = "#{expected_prefix}#{kind}"
                  # Replace class declaration and any plain references inside the file
                  content = content.gsub(/class\s+#{Regexp.escape(old_class)}\b/, "class #{expected_class}")
                  content = content.gsub(/\b#{Regexp.escape(old_class)}\b/, expected_class)
                  File.write(new_path, content)
                rescue StandardError => e2
                  warn("[RailsHmvc::Controllers::ActionOperationNaming] Class rename failed in #{new_path}: #{e2.message}")
                end
              end
            rescue StandardError => e
              warn("[RailsHmvc::Controllers::ActionOperationNaming] Rename failed: #{e.message}")
            end
          end
        end
      end
    end
  end
end
