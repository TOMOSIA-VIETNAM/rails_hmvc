module <%= version.camelize %>
  module <%= class_name.pluralize %>
    class UpdateOperation < <%= parent_operation_class %>
      def call
        step_load_<%= singular_name %>
        step_authorize
        step_validate_form
        step_update_<%= singular_name %>
      end

      private

      def step_load_<%= singular_name %>
        @<%= singular_name %> = <%= class_name %>.find(params[:id])
      end

      def step_authorize
        # Add authorization logic here
        true
      end

      def step_update_<%= singular_name %>
        @<%= singular_name %>.update!(form.attributes)
        @<%= singular_name %>
      end
    end
  end
end
