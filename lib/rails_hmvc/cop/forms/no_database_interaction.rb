# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsHmvc
      module Forms
        # Ensures that Form classes do not interact directly with database
        #
        # @example
        #   # bad
        #   class CreateUserForm < ApplicationForm
        #     validates :email, presence: true
        #
        #     def save
        #       User.create!(attributes)  # Direct database interaction
        #     end
        #
        #     def user_exists?
        #       User.exists?(email: email)  # Direct database query
        #     end
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
        class NoDatabaseInteraction < RuboCop::Cop::Base
          MSG = 'Form classes should not interact directly with database. Move database operations to Operations.'

          DATABASE_METHODS = %i[
            create create! new save save! update update! destroy destroy!
            find find_by find_by! where all first last
            count exists? delete delete_all
            transaction
            connection execute
          ].freeze

          def_node_matcher :form_class?, <<~PATTERN
            (class
              (const _ !nil)
              (const ...)
              ...)
          PATTERN

          def_node_matcher :model_constant_call?, <<~PATTERN
            (send (const _ _) $_ ...)
          PATTERN

          def_node_matcher :activerecord_method_call?, <<~PATTERN
            (send _ $_ ...)
          PATTERN

          def on_class(node)
            return unless form_class?(node)
            return unless form_file?(processed_source.file_path)

            check_class_for_database_calls(node)
          end

          private

          def form_file?(file_path)
            file_path.match?(%r{/forms/.*_form\.rb$})
          end

          def check_class_for_database_calls(class_node)
            class_node.each_descendant(:send) do |send_node|
              check_send_node_for_database_interaction(send_node)
            end
          end

          def check_send_node_for_database_interaction(send_node)
            method_name = send_node.children[1]
            return unless DATABASE_METHODS.include?(method_name)

            receiver = send_node.children[0]

            # Check for direct model calls: Model.method
            if receiver&.type == :const && looks_like_model?(receiver)
              add_offense(send_node, message: MSG)
              return
            end

            # Check for ActiveRecord connection calls
            if %i[connection execute].include?(method_name)
              add_offense(send_node, message: MSG)
              return
            end

            # Check for transaction blocks
            return unless method_name == :transaction

            add_offense(send_node, message: MSG)
            nil
          end

          def looks_like_model?(const_node)
            # Simple heuristic: constants that are likely models
            const_name = const_node.children[1].to_s
            const_name.match?(/^[A-Z][A-Za-z]*$/) &&
              (const_name.match?(/User|Product|Order|Category|Post|Comment|Item|Model/) ||
               const_name.length > 2)
          end
        end
      end
    end
  end
end
