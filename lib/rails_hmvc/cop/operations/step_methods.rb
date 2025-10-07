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
          extend AutoCorrector

          MSG = 'Operation `call` method should use step_ prefix for method calls: %<methods>s'

          def_node_matcher :operation_class?, <<~PATTERN
            (class ...)
          PATTERN

          def_node_matcher :call_method?, <<~PATTERN
            (def :call ...)
          PATTERN

          def_node_matcher :step_method_call?, <<~PATTERN
            (send nil /^step_/ ...)
          PATTERN

          def_node_matcher :method_call?, <<~PATTERN
            (send nil _ ...)
          PATTERN

          def on_class(node)
            file_path = processed_source.file_path

            # Debug info (can be removed in production)
            # puts "Checking class in file: #{file_path}" if ENV['RUBOCOP_DEBUG']

            return unless operation_class?(node)
            return unless operation_file?(file_path)

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

            # Check for method calls that should be step methods
            non_step_calls = find_non_step_method_calls(body)

            # If there are non-step method calls, report offense
            if non_step_calls.any?
              method_names = non_step_calls.map { |call| call.method_name.to_s }.join(', ')

              add_offense(call_method, message: format(MSG, methods: method_names)) do |corrector|
                auto_correct_method_calls(corrector, body, non_step_calls)
              end
            end
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

          def find_non_step_method_calls(body)
            calls = []

            case body.type
            when :begin
              body.children.each do |child|
                if method_call?(child) && !step_method_call?(child) && should_be_step_method?(child)
                  calls << child
                end
              end
            else
              if method_call?(body) && !step_method_call?(body) && should_be_step_method?(body)
                calls << body
              end
            end

            calls
          end

          def should_be_step_method?(node)
            return false unless node.type == :send
            return false if node.receiver # Only nil receiver (self methods)

            method_name = node.method_name.to_s

            # Skip methods that already have step_ prefix
            return false if method_name.start_with?('step_')

            # Skip common Ruby/Rails methods that shouldn't be prefixed
            skip_methods = %w[
              puts print p pp raise fail return next break
              attr_reader attr_writer attr_accessor
              before_action after_action around_action
              validates validate presence_of length_of
              belongs_to has_many has_one
              scope where find create update destroy
              save save! update! destroy!
              super
            ]

            # Skip getter/setter methods and Ruby built-ins
            return false if skip_methods.include?(method_name)
            return false if method_name.end_with?('=') # setter methods
            return false if method_name.end_with?('?') # predicate methods
            return false if method_name.end_with?('!') # bang methods

            # Only target method calls that look like step methods
            true
          end

          def auto_correct_method_calls(corrector, body, non_step_calls)
            non_step_calls.each do |call_node|
              method_name = call_node.method_name.to_s
              next if method_name.start_with?('step_')

              new_method_name = "step_#{method_name}"
              corrector.replace(call_node.loc.selector, new_method_name)
            end
          end
        end
      end
    end
  end
end
