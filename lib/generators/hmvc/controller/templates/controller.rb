# frozen_string_literal: true

<% module_namespacing do -%>
class <%= controller_class_name %> < <%= parent_controller_class %>
<% actions.each_with_index do |action, index| -%>
<%= "\n" if index > 0 %>  # <%= action_comment_for(action) %>
  def <%= action %>
<% unless skip_operations? -%>
    operator = <%= operation_class_for(action) %>.call(params:)

<% end -%>
<% if action == "index" -%>
    <%= render_for_action("index") %>
<% elsif action == "show" -%>
    <%= render_for_action("show") %>
<% elsif action == "new" -%>
    <%= render_for_action("new") %>
<% elsif action == "edit" -%>
    <%= render_for_action("edit") %>
<% elsif action == "create" -%>
    <%= render_for_action("create") %>
<% elsif action == "update" -%>
    <%= render_for_action("update") %>
<% elsif action == "destroy" -%>
    <%= render_for_action("destroy") %>
<% end -%>
  end
<% end -%>
end
<% end -%>
