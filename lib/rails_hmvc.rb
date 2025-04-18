# frozen_string_literal: true

require 'active_model'
require 'active_model_serializers'

require 'rails_hmvc/version'
require 'rails_hmvc/errors/exception_error'
require 'rails_hmvc/errors/resource_error'
require 'rails_hmvc/concerns/renderable'
require 'rails_hmvc/concerns/errorable'
require 'rails_hmvc/controllers/application_controller'
require 'rails_hmvc/forms/application_form'
require 'rails_hmvc/operations/application_operation'
require 'rails_hmvc/serializers/application_serializer'

module Rails
  module Hmvc
    class Error < StandardError; end
    # Your code goes here...
  end
end
