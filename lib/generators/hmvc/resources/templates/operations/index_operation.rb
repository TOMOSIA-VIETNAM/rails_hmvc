module <%= version.camelize %>
  module <%= class_name.pluralize %>
    class IndexOperation < <%= parent_operation_class %>
      def call
        step_authorize
        step_load_<%= plural_name %>
      end

      private

      def step_authorize
        # Add authorization logic here
        true
      end

      def step_load_<%= plural_name %>
        <%= class_name %>.page(params[:page]).per(params[:per_page])
      end
    end
  end
end
