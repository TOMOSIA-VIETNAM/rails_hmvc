module Rails
  module Hmvc
    module Concerns
      module Renderable
        extend ActiveSupport::Concern

        def render_success(data: nil, message: nil, status: :ok, meta: {})
          render json: {
            success: true,
            data: data,
            message: message,
            meta: meta
          }, status: status
        end

        def render_error(error:, status: :unprocessable_entity, data: nil)
          render json: {
            success: false,
            error: error,
            data: data
          }, status: status
        end

        def render_collection(collection:, serializer: nil, meta: {}, status: :ok, message: nil)
          options = {}
          options[:meta] = meta if meta.present?

          render json: {
            success: true,
            data: ActiveModelSerializers::SerializableResource.new(
              collection,
              each_serializer: serializer,
              adapter: :json
            ),
            message: message,
            meta: meta
          }, status: status
        end

        def render_resource(resource:, serializer: nil, meta: {}, status: :ok, message: nil)
          options = {}
          options[:meta] = meta if meta.present?

          render json: {
            success: true,
            data: ActiveModelSerializers::SerializableResource.new(
              resource,
              serializer: serializer,
              adapter: :json
            ),
            message: message,
            meta: meta
          }, status: status
        end
      end
    end
  end
end
