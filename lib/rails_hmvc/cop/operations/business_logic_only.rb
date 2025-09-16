# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsHmvc
      module Operations
        # Ensures that Operations contain business logic only, no direct model calls
        #
        # @example
        #   # bad
        #   class CreateUserOperation < ApplicationOperation
        #     def call
        #       User.create!(params)  # Direct database call
        #       Product.find(1)       # Direct database call
        #     end
        #   end
        #
        #   # good
        #   class CreateUserOperation < ApplicationOperation
        #     def call
        #       step_validate_user
        #       step_create_user
        #     end
        #
        #     private
        #
        #     def step_create_user
        #       User.create!(user_params)  # OK in step methods
        #     end
        #   end
        class BusinessLogicOnly < RuboCop::Cop::Base
          MSG = 'Operations should not contain direct model calls in `call` method. Use step methods instead.'

          DIRECT_MODEL_METHODS = %i[
            create create! new save save! update update! destroy destroy!
            find find_by find_by! where all first last
            count exists? delete delete_all
          ].freeze

          def_node_matcher :operation_class?, <<~PATTERN
            (class
              (const _ !nil)
              (const ...)
              ...)
          PATTERN

          def_node_matcher :call_method?, <<~PATTERN
            (def :call ...)
          PATTERN

          def_node_matcher :model_constant_call?, <<~PATTERN
            (send (const _ _) $_ ...)
          PATTERN

          def on_class(node)
            return unless operation_class?(node)
            return unless operation_file?(processed_source.file_path)

            call_method = find_call_method(node)
            return unless call_method

            check_call_method_for_direct_model_calls(call_method)
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

          def check_call_method_for_direct_model_calls(call_method)
            call_method.each_descendant(:send) do |send_node|
              next unless model_constant_call?(send_node)

              method_name = send_node.children[1]
              next unless DIRECT_MODEL_METHODS.include?(method_name)

              # Check if this is a direct model call (receiver is a constant)
              receiver = send_node.children[0]
              add_offense(send_node, message: MSG) if receiver&.type == :const && looks_like_model?(receiver)
            end
          end

          def looks_like_model?(const_node)
            # Simple heuristic: constants that are likely models
            # (capitalized names, often ending with common model patterns)
            const_name = const_node.children[1].to_s
            const_name.match?(/^[A-Z][A-Za-z]*$/) &&
              (const_name.match?(/User|Product|Order|Category|Post|Comment|Item/) ||
               const_name.length > 2)
          end
        end
      end
    end
  end
end
