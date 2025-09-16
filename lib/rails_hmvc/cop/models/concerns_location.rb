# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsHmvc
      module Models
        # Ensures that extended logic in Models is moved to Concerns
        #
        # @example
        #   # bad
        #   class User < ApplicationRecord
        #     validates :email, presence: true
        #
        #     # Complex business methods should be in concerns
        #     def full_name_with_title
        #       title = determine_title_based_on_age_and_status
        #       formatted_title = format_title_for_display(title)
        #       "#{formatted_title} #{first_name} #{last_name}"
        #     end
        #
        #     def determine_title_based_on_age_and_status
        #       # 20+ lines of complex logic
        #     end
        #
        #     def format_title_for_display(title)
        #       # 10+ lines of formatting logic
        #     end
        #   end
        #
        #   # good
        #   class User < ApplicationRecord
        #     include UserNameFormatting
        #     include UserStatusManagement
        #
        #     validates :email, presence: true
        #
        #     # Simple methods are OK
        #     def full_name
        #       "#{first_name} #{last_name}"
        #     end
        #   end
        class ConcernsLocation < RuboCop::Cop::Base
          MSG = 'Complex model methods should be extracted to concerns. ' \
                'Method `%<method_name>s` has %<lines>d lines.'

          MAX_METHOD_LINES = 5
          MAX_MODEL_METHODS = 8

          ALLOWED_SIMPLE_METHODS = %i[
            to_s to_param full_name display_name
            active? inactive? valid? persisted?
          ].freeze

          RAILS_METHODS = %i[
            validates validates_presence_of validates_length_of validates_format_of
            validates_inclusion_of validates_exclusion_of validates_confirmation_of
            validates_acceptance_of validates_uniqueness_of validates_numericality_of
            validate
            scope default_scope
            has_one has_many belongs_to has_and_belongs_to_many
            before_save after_save before_create after_create
            before_update after_update before_destroy after_destroy
            before_validation after_validation
            attr_accessor attr_reader attr_writer
            delegate
            enum
          ].freeze

          def_node_matcher :model_class?, <<~PATTERN
            (class
              (const _ !nil)
              (const ...)
              ...)
          PATTERN

          def on_class(node)
            return unless model_class?(node)
            return unless model_file?(processed_source.file_path)

            check_model_complexity(node)
          end

          private

          def model_file?(file_path)
            file_path.match?(%r{/models/.*\.rb$}) &&
              !file_path.match?(%r{/models/concerns/})
          end

          def check_model_complexity(class_node)
            class_body = class_node.body
            return unless class_body

            methods = extract_methods(class_body)

            # Check individual method complexity
            methods.each { |method| check_method_complexity(method) }

            # Check overall model complexity
            check_overall_model_complexity(methods, class_node)
          end

          def extract_methods(class_body)
            nodes = if class_body.type == :begin
                      class_body.children
                    else
                      [class_body]
                    end

            nodes.select { |node| node.type == :def }
          end

          def check_method_complexity(method_node)
            method_name = method_node.method_name
            return if ALLOWED_SIMPLE_METHODS.include?(method_name)
            return if method_name.to_s.start_with?('_') # private methods marker

            line_count = count_method_lines(method_node)

            return unless line_count > MAX_METHOD_LINES

            add_offense(
              method_node,
              message: format(MSG, method_name: method_name, lines: line_count)
            )
          end

          def check_overall_model_complexity(methods, class_node)
            custom_methods = methods.reject do |method|
              method_name = method.method_name
              RAILS_METHODS.include?(method_name) ||
                ALLOWED_SIMPLE_METHODS.include?(method_name) ||
                method_name.to_s.start_with?('_')
            end

            return unless custom_methods.length > MAX_MODEL_METHODS

            add_offense(
              class_node.children[0],
              message: "Model has #{custom_methods.length} custom methods. " \
                       'Consider extracting some to concerns.'
            )
          end

          def count_method_lines(method_node)
            return 1 unless method_node.body

            case method_node.body.type
            when :begin
              method_node.body.children.length
            else
              1
            end
          end
        end
      end
    end
  end
end
