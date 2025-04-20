# frozen_string_literal: true

class <%= namespace_name %>::<%= operation_class_name %>Operation < <%= parent_operation_class %>
<% if step_methods.any? -%>
  def call
    <%= step_methods.join("\n    ") %>
  end
<% else -%>
  def call
  end
<% end -%>

  private
<% if step_methods.any? -%>
<% step_methods.each do |step_method| %>
  def <%= step_method %>
    # TODO: Implement logic
  end
<% end -%>
<% end -%>
end
