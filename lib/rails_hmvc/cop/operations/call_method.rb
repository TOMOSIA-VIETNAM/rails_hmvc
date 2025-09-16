# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsHmvc
      module Operations
        # Ensures that Operation classes have a `call` method
        #
        # @example
        #   # bad
        #   class CreateUserOperation < ApplicationOperation
        #     def execute
        #       # business logic
        #     end
        #   end
        #
        #   # good
        #   class CreateUserOperation < ApplicationOperation
        #     def call
        #       # business logic
        #     end
        #   end
        class CallMethod < RuboCop::Cop::Base
          MSG = "Operation classes must have a `call` method"

          def_node_matcher :operation_class?, <<~PATTERN
            (class
              (const _ !nil)
              (const ...)
              ...)
          PATTERN

          def_node_matcher :call_method?, <<~PATTERN
            (def :call ...)
          PATTERN

          def on_class(node)
            return unless operation_class?(node)
            return unless operation_file?(processed_source.file_path)

            class_body = node.body
            return unless class_body

            has_call_method = if class_body.type == :begin
                                class_body.children.any? { |child| call_method?(child) }
                              else
                                call_method?(class_body)
                              end

            add_offense(node.children[0]) unless has_call_method
          end

          private

          def operation_file?(file_path)
            file_path.match?(%r{/operations/.*_operation\.rb$})
          end
        end
      end
    end
  end
end
