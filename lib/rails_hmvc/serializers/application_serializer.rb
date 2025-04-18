module Rails
  module Hmvc
    module Serializers
      class ApplicationSerializer < ActiveModel::Serializer
        def created_at
          object.created_at.iso8601 if object.respond_to?(:created_at)
        end

        def updated_at
          object.updated_at.iso8601 if object.respond_to?(:updated_at)
        end
      end
    end
  end
end
