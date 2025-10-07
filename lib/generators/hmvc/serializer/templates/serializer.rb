class <%= namespace_name %>::<%= serializer_class_name %>Serializer < <%= parent_serializer_class %>
<% if attribute_definitions -%>
<%= attribute_definitions %>
<% if association_definitions -%>
<%= association_definitions %>
<% end -%>

<% end -%>
end
