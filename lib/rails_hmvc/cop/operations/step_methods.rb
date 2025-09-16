# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsHmvc
      module Operations
        # Ensures that Operation `call` method delegates to step methods
        #
        # @example
        #   # bad
        #   class CreateUserOperation < ApplicationOperation
        #     def call
        #       User.create!(params)
        #     end
        #   end
        #
        #   # good
        #   class CreateUserOperation < ApplicationOperation
        #     def call
        #       step_validate_params
        #       step_create_user
        #       step_send_notification
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
        #
        #     def step_send_notification
        #       # notification logic
        #     end
        #   end
        class StepMethods < RuboCop::Cop::Base
          MSG = 'Operation `call` method should delegate to private step methods (prefix: step_)'

          def_node_matcher :operation_class?, <<~PATTERN
            (class
              (const _ !nil)
              (const ...)
              ...)
          PATTERN

          def_node_matcher :call_method?, <<~PATTERN
            (def :call ...)
          PATTERN

          def_node_matcher :step_method_call?, <<~PATTERN
            (send nil /^step_/ ...)
          PATTERN

          def on_class(node)
            return unless operation_class?(node)
            return unless operation_file?(processed_source.file_path)

            call_method = find_call_method(node)
            return unless call_method

            check_call_method_body(call_method)
          end

          private

          def operation_file?(file_path)
            file_path.match?(%r{/operations/.*_operation\.rb$})
          end

          def find_call_method(class_node)
            class_body = class_node.body
            return unless class_body

            if class_body.type == :begin
              class_body.children.find { |child| call_method?(child) }
            else
              call_method?(class_body) ? class_body : nil
            end
          end

          def check_call_method_body(call_method)
            body = call_method.body
            return unless body

            has_step_calls = if body.type == :begin
                               body.children.any? { |statement| step_method_call?(statement) }
                             else
                               step_method_call?(body)
                             end

            # Only warn if method has actual logic but no step calls
            return unless has_business_logic?(body) && !has_step_calls

            add_offense(call_method, message: MSG)
          end

          def has_business_logic?(body)
            return false unless body

            case body.type
            when :begin
              body.children.any? { |child| !comment_or_empty?(child) }
            else
              !comment_or_empty?(body)
            end
          end

          def comment_or_empty?(node)
            return true if node.nil?
            return true if node.type == :nil

            false
          end
        end
      end
    end
  end
end
