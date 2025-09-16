# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsHmvc
      module Forms
        # Ensures that Form classes only contain validation logic
        #
        # @example
        #   # bad
        #   class CreateUserForm < ApplicationForm
        #     scope :active, -> { where(active: true) }
        #     delegate :name, to: :user
        #     has_one :profile
        #     belongs_to :organization
        #
        #     validates :email, presence: true
        #   end
        #
        #   # good
        #   class CreateUserForm < ApplicationForm
        #     attribute :email, :string
        #     attribute :name, :string
        #
        #     validates :email, presence: true
        #     validates :name, length: { minimum: 2 }
        #
        #     def valid!
        #       raise ExceptionError::UnprocessableEntity, error_messages.to_json unless valid?
        #     end
        #   end
        class ValidationOnly < RuboCop::Cop::Base
          MSG = 'Form classes should only contain validation logic. Move %<method>s to model or concern.'

          FORBIDDEN_METHODS = %i[
            scope delegate has_one has_many belongs_to has_and_belongs_to_many
            before_save after_save before_create after_create
            before_update after_update before_destroy after_destroy
            before_validation after_validation
          ].freeze

          ALLOWED_FORM_METHODS = %i[
            validates validates_presence_of validates_length_of validates_format_of
            validates_inclusion_of validates_exclusion_of validates_confirmation_of
            validates_acceptance_of validates_uniqueness_of validates_numericality_of
            validate
            attribute attributes
            valid valid! invalid?
            errors error_messages
            initialize
          ].freeze

          def_node_matcher :form_class?, <<~PATTERN
            (class
              (const _ !nil)
              (const ...)
              ...)
          PATTERN

          def on_class(node)
            return unless form_class?(node)
            return unless form_file?(processed_source.file_path)

            check_class_body_for_forbidden_methods(node)
          end

          def on_send(node)
            return unless form_file?(processed_source.file_path)
            return if node.receiver

            method_name = node.method_name
            return unless FORBIDDEN_METHODS.include?(method_name)

            add_offense(node, message: format(MSG, method: method_name))
          end

          private

          def form_file?(file_path)
            file_path.match?(%r{/forms/.*_form\.rb$})
          end

          def check_class_body_for_forbidden_methods(class_node)
            class_body = class_node.body
            return unless class_body

            nodes_to_check = if class_body.type == :begin
                               class_body.children
                             else
                               [class_body]
                             end

            nodes_to_check.each do |node|
              check_node_for_forbidden_methods(node)
            end
          end

          def check_node_for_forbidden_methods(node)
            case node.type
            when :send
              method_name = node.method_name
              if FORBIDDEN_METHODS.include?(method_name) && !node.receiver
                add_offense(node, message: format(MSG, method: method_name))
              end
            when :def
              # Allow only certain method definitions
              method_name = node.method_name
              unless ALLOWED_FORM_METHODS.include?(method_name) ||
                     method_name.to_s.start_with?('valid')
                add_offense(node, message: format(MSG, method: method_name))
              end
            end
          end
        end
      end
    end
  end
end
