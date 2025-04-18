require_relative 'api_error'

module Errors
  class ResourceError < APIError
    attr_reader :resource, :errors

    def initialize(resource:, message: nil, status: 422, code: 'resource_error', detail: nil)
      @resource = resource
      @errors = message.is_a?(Array) ? message : [message]
      super(message || "Error with resource #{resource}", status: status, code: code, detail: detail)
    end

    def to_hash
      super.merge(resource: @resource)
    end
  end
end
