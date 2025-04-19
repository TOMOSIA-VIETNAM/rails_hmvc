module <%= version.camelize %>
  module <%= class_name.pluralize %>
    class CreateOperation < <%= parent_operation_class %>
      def call
        step_authorize
        step_validate_form
        step_create_<%= singular_name %>
      end

      private

      def step_authorize
        # Add authorization logic here
        true
      end

      def step_create_<%= singular_name %>
        @<%= singular_name %> = <%= class_name %>.create!(form.attributes)
      end
    end
  end
end
