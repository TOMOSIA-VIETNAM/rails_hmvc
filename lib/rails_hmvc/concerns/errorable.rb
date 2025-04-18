module Rails
  module Hmvc
    module Concerns
      module Errorable
        extend ActiveSupport::Concern

        included do
          rescue_from StandardError, with: :handle_standard_error
          rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
          rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
          rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
        end

        private

        def handle_standard_error(exception)
          Rails.logger.error(exception.message)
          Rails.logger.error(exception.backtrace.join("\n"))

          render_error(
            error: exception.message,
            status: :internal_server_error
          )
        end

        def handle_not_found(exception)
          render_error(
            error: exception.message,
            status: :not_found
          )
        end

        def handle_validation_error(exception)
          render_error(
            error: exception.record.errors.full_messages,
            status: :unprocessable_entity
          )
        end

        def handle_parameter_missing(exception)
          render_error(
            error: exception.message,
            status: :bad_request
          )
        end

        def handle_authorization_error(exception)
          render_error(
            error: exception.message,
            status: :forbidden
          )
        end

        def handle_authentication_error(exception)
          render_error(
            error: exception.message,
            status: :unauthorized
          )
        end
      end
    end
  end
end
