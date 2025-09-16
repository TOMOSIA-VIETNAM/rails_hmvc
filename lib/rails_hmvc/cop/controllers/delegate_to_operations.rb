# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsHmvc
      module Controllers
        # Ensures that Controller actions delegate to Operations
        #
        # @example
        #   # bad
        #   class UsersController < ApplicationController
        #     def create
        #       user = User.create!(user_params)
        #       render json: user
        #     end
        #
        #     def update
        #       user = User.find(params[:id])
        #       user.update!(user_params)
        #       render json: user
        #     end
        #   end
        #
        #   # good
        #   class UsersController < ApplicationController
        #     def create
        #       operator = User::CreateOperation.call(params: user_params)
        #       render json: operator.result
        #     end
        #
        #     def index
        #       # Simple renders without business logic are OK
        #       render :index
        #     end
        #   end
        class DelegateToOperations < RuboCop::Cop::Base
          MSG = 'Controller actions should delegate to Operations for business logic'

          SIMPLE_ACTIONS = %i[render redirect_to head].freeze
          BUSINESS_ACTIONS = %i[create update destroy].freeze

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

          def_node_matcher :operation_call?, <<~PATTERN
            (send
              (const
                (const _ _) _)
              :call
              ...)
          PATTERN

          def_node_matcher :simple_render?, <<~PATTERN
            (send nil {:render :redirect_to :head} ...)
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

            actions.each { |action| check_action_delegation(action) }
          end

          def check_action_delegation(action_node)
            action_name = action_node.method_name
            action_body = action_node.body
            return unless action_body

            # Skip if action is just simple renders
            return if only_simple_renders?(action_body)

            # Business actions should have operation calls
            if BUSINESS_ACTIONS.include?(action_name)
              add_offense(action_node, message: MSG) unless has_operation_call?(action_body)
            elsif has_business_logic?(action_body) && !has_operation_call?(action_body)
              # Any action with business logic should delegate to operations
              add_offense(action_node, message: MSG)
            end
          end

          def only_simple_renders?(body)
            case body.type
            when :begin
              body.children.all? { |child| simple_action?(child) }
            else
              simple_action?(body)
            end
          end

          def simple_action?(node)
            return true if node.nil?

            case node.type
            when :send
              method_name = node.method_name
              SIMPLE_ACTIONS.include?(method_name) || simple_render?(node)
            else
              false
            end
          end

          def has_operation_call?(body)
            case body.type
            when :begin
              body.children.any? { |child| contains_operation_call?(child) }
            else
              contains_operation_call?(body)
            end
          end

          def contains_operation_call?(node)
            return false unless node

            # Direct operation call
            return true if operation_call?(node)

            # Assignment with operation call: operator = SomeOperation.call(...)
            return operation_call?(node.children[1]) if %i[lvasgn ivasgn].include?(node.type)

            # Check descendants for operation calls
            node.each_descendant do |descendant|
              return true if operation_call?(descendant)
            end

            false
          end

          def has_business_logic?(body)
            return false unless body

            case body.type
            when :begin
              body.children.any? { |child| is_business_logic?(child) }
            else
              is_business_logic?(body)
            end
          end

          def is_business_logic?(node)
            return false unless node
            return false if simple_action?(node)

            case node.type
            when :send
              receiver = node.children[0]
              method_name = node.method_name

              # Model calls are business logic
              return true if receiver&.type == :const && looks_like_model?(receiver)

              # Complex method calls are business logic
              %i[create create! update update! save save! destroy].include?(method_name)
            when :if, :unless, :case, :block
              # Conditionals and blocks often contain business logic
              true
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
