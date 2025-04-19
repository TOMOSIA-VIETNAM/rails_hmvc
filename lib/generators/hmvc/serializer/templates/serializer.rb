# frozen_string_literal: true

<% module_namespacing do -%>
class <%= serializer_class_name %> < <%= parent_serializer_class %>
  attributes <%= attributes_list.map { |attr| ":#{attr}" }.join(', ') %>
<% associations = parse_associations %>

<% associations[:belongs_to].each do |assoc| -%>
  belongs_to :<%= assoc %>
<% end -%>

<% associations[:has_many].each do |assoc| -%>
  has_many :<%= assoc %>
<% end -%>

<% associations[:has_one].each do |assoc| -%>
  has_one :<%= assoc %>
<% end -%>
end
<% end -%>
