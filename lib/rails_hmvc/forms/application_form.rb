module Rails
  module Hmvc
    module Forms
      class ApplicationForm
        include ActiveModel::Model
        include ActiveModel::Attributes
        include ActiveModel::Validations::Callbacks

        def valid!
          raise Rails::Hmvc::Errors::UnprocessableEntity.new(error_messages) unless valid?
          true
        end

        private

        def error_messages
          errors.messages.transform_values(&:first)
        end
      end
    end
  end
end
