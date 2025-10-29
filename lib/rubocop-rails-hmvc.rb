# frozen_string_literal: true

# RuboCop extension for Rails HMVC
# This file loads all custom cops for enforcing HMVC architecture

require 'rubocop'

# Load all custom cops
require_relative 'rails_hmvc/cop/operations/call_method'
require_relative 'rails_hmvc/cop/operations/step_methods'
require_relative 'rails_hmvc/cop/operations/step_method_definitions'
require_relative 'rails_hmvc/cop/operations/restful_naming'
require_relative 'rails_hmvc/cop/operations/business_logic_only'
require_relative 'rails_hmvc/cop/forms/validation_only'
require_relative 'rails_hmvc/cop/forms/no_database_interaction'
require_relative 'rails_hmvc/cop/forms/restful_naming'
require_relative 'rails_hmvc/cop/controllers/no_business_logic'
require_relative 'rails_hmvc/cop/controllers/delegate_to_operations'
require_relative 'rails_hmvc/cop/controllers/pluralized_filename'
require_relative 'rails_hmvc/cop/controllers/action_operation_naming'
require_relative 'rails_hmvc/cop/models/concerns_location'
