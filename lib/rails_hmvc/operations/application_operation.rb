module Rails
  module Hmvc
    module Operations
      class ApplicationOperation
        attr_reader :params, :current_user, :form

        def initialize(params = {}, context = {})
          @params = params
          @current_user = context[:current_user]
          @form = context[:form]
        end

        def self.call(params = {}, context = {})
          new(params, context).call
        end

        def call
          raise NotImplementedError, "#{self.class} must implement #call"
        end

        protected

        def step_validate_form
          form.valid! if form.present?
        end

        def step_authorize(policy_class, action)
          return true unless defined?(Pundit)

          policy = policy_class.new(current_user, form || params)
          raise Rails::Hmvc::Errors::Forbidden unless policy.public_send(action)
        end
      end
    end
  end
end
