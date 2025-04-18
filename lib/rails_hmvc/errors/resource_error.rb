module Rails
  module Hmvc
    module Errors
      class ResourceError
        def self.format(error)
          case error
          when ActiveRecord::RecordNotFound
            { message: error.message, status: :not_found }
          when ActiveRecord::RecordInvalid
            { message: error.record.errors.full_messages, status: :unprocessable_entity }
          when ActionController::ParameterMissing
            { message: error.message, status: :bad_request }
          when Rails::Hmvc::Errors::UnprocessableEntity
            { message: error.message, status: :unprocessable_entity, details: error.details }
          when Rails::Hmvc::Errors::NotFound
            { message: error.message, status: :not_found, details: error.details }
          when Rails::Hmvc::Errors::Unauthorized
            { message: error.message, status: :unauthorized, details: error.details }
          when Rails::Hmvc::Errors::Forbidden
            { message: error.message, status: :forbidden, details: error.details }
          when Rails::Hmvc::Errors::BadRequest
            { message: error.message, status: :bad_request, details: error.details }
          else
            { message: error.message, status: :internal_server_error }
          end
        end
      end
    end
  end
end
