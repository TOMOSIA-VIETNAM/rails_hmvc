# frozen_string_literal: true

<% module_namespacing do -%>
class <%= controller_class_name %> < <%= parent_controller_class %>
<% actions.each do |action| -%>
  # [<%= action == "index" ? "GET" : action == "show" ? "GET" : action == "create" ? "POST" : action == "update" ? "PUT" : "DELETE" %>] /<%= namespace_path %>/<%= plural_name %><%= action == "show" || action == "update" || action == "destroy" ? "/:id" : "" %>
  def <%= action %>
<% unless skip_operations? -%>
    result = <%= operation_class_for(action) %>.call(<%= action == "update" || action == "create" ? "#{action}_params" : "params" %>)
<% end -%>
<% if action == "index" -%>
    render_collection(
      collection: result,
      serializer: <%= serializer_class %>
<% if action == "index" -%>
      meta: pagination_meta(result)
<% end -%>
    )
<% elsif action == "show" || action == "create" || action == "update" -%>
    render_resource(
      resource: result,
      serializer: <%= serializer_class %><% if action == "create" %>,
      status: :created<% end %>
    )
<% elsif action == "destroy" -%>
    head :no_content
<% end -%>
  end

<% end -%>
<% if actions.include?("create") || actions.include?("update") -%>
  private

<% if actions.include?("create") -%>
  def create_params
<% unless skip_forms? -%>
    form = <%= form_class_for("create") %>.new(params.require(:<%= singular_name %>).permit!)
    form.valid!
    form.attributes
<% else -%>
    params.require(:<%= singular_name %>).permit(
      # Add permitted parameters here
    )
<% end -%>
  end
<% end -%>

<% if actions.include?("update") -%>
  def update_params
<% unless skip_forms? -%>
    form = <%= form_class_for("update") %>.new(params.require(:<%= singular_name %>).permit!)
    form.valid!
    form.attributes
<% else -%>
    params.require(:<%= singular_name %>).permit(
      # Add permitted parameters here
    )
<% end -%>
  end
<% end -%>
<% end -%>
end
<% end -%>
