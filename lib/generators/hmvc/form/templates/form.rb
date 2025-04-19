# frozen_string_literal: true

class <%= namespace_name %>::<%= form_class_name %> < <%= parent_form_class %>
<% if attribute_definitions.present? -%>
  # Define form attributes
<%= attribute_definitions %>

  # Define validations
<%= validation_definitions %>
<% end -%>
end
