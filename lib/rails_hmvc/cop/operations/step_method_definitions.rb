# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsHmvc
      module Operations
        # Ensures that private methods in Operations have step_ prefix
        #
        # @example
        #   # bad
        #   class CreateUserOperation < ApplicationOperation
        #     def call
        #       validate_params
        #       create_user
        #     end
        #
        #     private
        #
        #     def validate_params
        #       # validation logic
        #     end
        #
        #     def create_user
        #       # creation logic
        #     end
        #   end
        #
        #   # good
        #   class CreateUserOperation < ApplicationOperation
        #     def call
        #       step_validate_params
        #       step_create_user
        #     end
        #
        #     private
        #
        #     def step_validate_params
        #       # validation logic
        #     end
        #
        #     def step_create_user
        #       # creation logic
        #     end
        #   end
        class StepMethodDefinitions < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Private methods in Operations should have step_ prefix: %<method_name>s -> step_%<method_name>s'

          def_node_matcher :operation_class?, <<~PATTERN
            (class ...)
          PATTERN

          def on_class(node)
            return unless operation_class?(node)
            return unless operation_file?(processed_source.file_path)

            check_private_methods(node)
          end

          private

          def operation_file?(file_path)
            file_path.match?(%r{/operations/.*_operation\.rb$})
          end

          def check_private_methods(class_node)
            private_section = find_private_section(class_node)
            return unless private_section

            methods_after_private = collect_methods_after_private(class_node, private_section)

            methods_after_private.each do |method_def|
              method_name = method_def.method_name.to_s
              next if method_name.start_with?('step_')
              next if skip_method?(method_name)

              add_offense(
                method_def,
                message: format(MSG, method_name: method_name)
              ) do |corrector|
                new_method_name = "step_#{method_name}"
                corrector.replace(method_def.loc.name, new_method_name)
              end
            end
          end

          def find_private_section(class_node)
            class_body = class_node.body
            return unless class_body

            nodes = class_body.type == :begin ? class_body.children : [class_body]

            nodes.find do |node|
              node.type == :send &&
              node.receiver.nil? &&
              node.method_name == :private &&
              node.arguments.empty?
            end
          end

          def collect_methods_after_private(class_node, private_node)
            class_body = class_node.body
            return [] unless class_body

            nodes = class_body.type == :begin ? class_body.children : [class_body]

            private_index = nodes.index(private_node)
            return [] unless private_index

            methods = []
            nodes[(private_index + 1)..-1].each do |node|
              if node.type == :def
                methods << node
              end
            end

            methods
          end

          def skip_method?(method_name)
            # Skip standard Ruby methods and common patterns
            skip_methods = %w[
              initialize
              to_s to_h to_a to_json
              inspect
              hash eql? ==
              respond_to? method_missing
              attr_reader attr_writer attr_accessor
            ]

            skip_methods.include?(method_name) ||
            method_name.end_with?('?') ||
            method_name.end_with?('!')
          end
        end
      end
    end
  end
end
