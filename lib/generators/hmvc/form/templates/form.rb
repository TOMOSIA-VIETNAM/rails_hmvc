# frozen_string_literal: true

class <%= namespace_name %>::<%= form_class_name %>Form < <%= parent_form_class %>
<% if attribute_definitions.present? -%>
  # ─────────────────────────────────────────────────────────────────────────────
  # Attributes
  # ─────────────────────────────────────────────────────────────────────────────
<%= attribute_definitions %>

  # ─────────────────────────────────────────────────────────────────────────────
  # Validations
  # ─────────────────────────────────────────────────────────────────────────────
<%= validation_definitions %>
<% end -%>
end
