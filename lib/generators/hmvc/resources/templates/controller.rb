module <%= version.camelize %>
  class <%= class_name.pluralize %>Controller < <%= parent_controller_class %>
    def index
      result = <%= version.camelize %>::<%= class_name.pluralize %>::IndexOperation.call(params)
      render_collection(
        collection: result,
        serializer: <%= version.camelize %>::<%= class_name %>Serializer,
        meta: pagination_meta(result)
      )
    end

    def show
      result = <%= version.camelize %>::<%= class_name.pluralize %>::ShowOperation.call(params)
      render_resource(
        resource: result,
        serializer: <%= version.camelize %>::<%= class_name %>Serializer
      )
    end

    def create
      form = <%= version.camelize %>::<%= class_name.pluralize %>::CreateForm.new(create_params)
      result = <%= version.camelize %>::<%= class_name.pluralize %>::CreateOperation.call(
        params,
        form: form,
        current_user: current_user
      )
      render_resource(
        resource: result,
        serializer: <%= version.camelize %>::<%= class_name %>Serializer,
        status: :created
      )
    end

    def update
      form = <%= version.camelize %>::<%= class_name.pluralize %>::UpdateForm.new(update_params)
      result = <%= version.camelize %>::<%= class_name.pluralize %>::UpdateOperation.call(
        params,
        form: form,
        current_user: current_user
      )
      render_resource(
        resource: result,
        serializer: <%= version.camelize %>::<%= class_name %>Serializer
      )
    end

    def destroy
      <%= version.camelize %>::<%= class_name.pluralize %>::DestroyOperation.call(
        params,
        current_user: current_user
      )
      head :no_content
    end

    private

    def create_params
      params.require(:<%= singular_name %>).permit(
        # Add permitted parameters here
      )
    end

    def update_params
      params.require(:<%= singular_name %>).permit(
        # Add permitted parameters here
      )
    end
  end
end
