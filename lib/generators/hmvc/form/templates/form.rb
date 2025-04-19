# frozen_string_literal: true

<% if namespaced? -%>
require_dependency '<%= namespaced_path %>/application_form' rescue LoadError

<% end -%>
<% module_namespacing do -%>
class <%= namespaced_class_name %> < ApplicationForm
  # Define form attributes
<% if attribute_definitions.present? -%>
<%= attribute_definitions %>
<% end -%>

  # Define validations
<% if validation_definitions.present? -%>
<%= validation_definitions %>
<% end -%>

  # Override this method to customize attribute transformation before validation
  # def transform_attributes
  #   super
  # end

  # Override this method to add custom validation logic
  # def custom_validate
  #   super
  # end
end
<% end -%>
