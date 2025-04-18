module <%= version.camelize %>
  module <%= class_name.pluralize %>
    class ShowOperation < <%= parent_operation_class %>
      def call
        step_load_<%= singular_name %>
        step_authorize
        @<%= singular_name %>
      end

      private

      def step_load_<%= singular_name %>
        @<%= singular_name %> = <%= class_name %>.find(params[:id])
      end

      def step_authorize
        # Add authorization logic here
        true
      end
    end
  end
end
