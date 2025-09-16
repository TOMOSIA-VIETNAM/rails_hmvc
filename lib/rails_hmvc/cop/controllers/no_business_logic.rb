# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsHmvc
      module Controllers
        # Ensures that Controller classes do not contain business logic
        #
        # @example
        #   # bad
        #   class UsersController < ApplicationController
        #     def create
        #       user = User.new(user_params)
        #       if user.email.present?
        #         user.name = user.name.titleize
        #         user.save!
        #         UserMailer.welcome_email(user).deliver_now
        #         render json: user
        #       else
        #         render json: { errors: ['Email required'] }
        #       end
        #     end
        #   end
        #
        #   # good
        #   class UsersController < ApplicationController
        #     def create
        #       operator = User::CreateOperation.call(params: user_params)
        #       if operator.success?
        #         render json: operator.result
        #       else
        #         render json: { errors: operator.errors }
        #       end
        #     end
        #   end
        class NoBusinessLogic < RuboCop::Cop::Base
          MSG = 'Controllers should not contain business logic. Move logic to Operations.'

          BUSINESS_LOGIC_PATTERNS = [
            # Complex conditionals with business rules
            :if, :unless, :case,
            # Loops that process business data
            :while, :until, :for,
            # String/data manipulation
            :+, :-, :*, :/, :%, :**
            # Method calls that look like business logic
          ].freeze

          ALLOWED_CONTROLLER_PATTERNS = %i[
            render redirect_to head
            before_action after_action around_action
            params require permit
            current_user authenticate_user!
            authorize
          ].freeze

          def_node_matcher :controller_class?, <<~PATTERN
            (class
              (const _ !nil)
              (const ...)
              ...)
          PATTERN

          def_node_matcher :controller_action?, <<~PATTERN
            (def {
              :index :show :new :edit :create :update :destroy
              :login :logout :register
            } ...)
          PATTERN

          def on_class(node)
            return unless controller_class?(node)
            return unless controller_file?(processed_source.file_path)

            check_controller_actions(node)
          end

          private

          def controller_file?(file_path)
            file_path.match?(%r{/controllers/.*_controller\.rb$})
          end

          def check_controller_actions(class_node)
            class_body = class_node.body
            return unless class_body

            actions = if class_body.type == :begin
                        class_body.children.select { |child| controller_action?(child) }
                      else
                        controller_action?(class_body) ? [class_body] : []
                      end

            actions.each { |action| check_action_for_business_logic(action) }
          end

          def check_action_for_business_logic(action_node)
            action_body = action_node.body
            return unless action_body

            # Check for complex business logic patterns
            check_for_business_logic_patterns(action_body)
          end

          def check_for_business_logic_patterns(node)
            return unless node

            case node.type
            when :begin
              node.children.each { |child| check_for_business_logic_patterns(child) }
            when :if, :unless
              # Allow simple success/error handling, flag complex business conditionals
              check_conditional_for_business_logic(node)
            when :send
              check_send_for_business_logic(node)
            when :block
              # Check block content
              check_for_business_logic_patterns(node.body) if node.body
            end
          end

          def check_conditional_for_business_logic(node)
            condition = node.children[0]

            # Simple success checks are OK: if operator.success?
            return if simple_success_check?(condition)

            # Complex business rules are not OK
            return unless complex_business_condition?(condition)

            add_offense(node, message: MSG)
          end

          def check_send_for_business_logic(node)
            method_name = node.method_name
            receiver = node.children[0]

            # Direct model calls are business logic
            if receiver&.type == :const && looks_like_model?(receiver) && !%i[find find_by].include?(method_name)
              add_offense(node, message: MSG) # Simple finds might be OK
            end

            # String/data manipulation is business logic
            return unless %i[+ - * / % ** << downcase upcase titleize strip].include?(method_name)

            add_offense(node, message: MSG)
          end

          def simple_success_check?(condition)
            return false unless condition&.type == :send

            method_name = condition.method_name
            %i[success? valid? present? blank? nil?].include?(method_name)
          end

          def complex_business_condition?(condition)
            # This is a simplified check - could be enhanced
            case condition.type
            when :and, :or
              true # Multiple conditions often indicate business logic
            when :send
              method_name = condition.method_name
              receiver = condition.children[0]

              # Checks on domain objects are business logic
              if %i[lvar ivar].include?(receiver&.type)
                !%i[present? blank? nil? valid? success?].include?(method_name)
              else
                false
              end
            else
              false
            end
          end

          def looks_like_model?(const_node)
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
