require_relative 'base_error'

module Errors
  class APIError < BaseError
    def initialize(message = nil, status: 500, code: 'api_error', detail: nil)
      super(message, status: status, code: code, detail: detail)
    end
  end
end
