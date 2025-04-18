module Rails
  module Hmvc
    module Errors
      class BaseError < StandardError
        attr_reader :message, :details

        def initialize(message = nil, details = nil)
          @message = message
          @details = details
          super(message)
        end
      end

      class UnprocessableEntity < BaseError; end
      class NotFound < BaseError; end
      class Unauthorized < BaseError; end
      class Forbidden < BaseError; end
      class BadRequest < BaseError; end
      class InternalServerError < BaseError; end
    end
  end
end
