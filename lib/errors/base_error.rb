# frozen_string_literal: true

module Errors
  class BaseError < StandardError
    attr_reader :status, :code, :detail

    def initialize(message = nil, status: nil, code: nil, detail: nil)
      @status = status
      @code = code
      @detail = detail

      super(message)
    end

    def to_hash
      {
        status: status,
        code: code,
        message: message,
        detail: detail
      }.compact
    end
  end
end
