# frozen_string_literal: true

require_relative "base_error"

module Errors
  class APIError < BaseError
    def initialize(message = nil, status: 500, code: "api_error", detail: nil)
      super
    end
  end
end
