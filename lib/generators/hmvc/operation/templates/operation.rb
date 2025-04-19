module <%= namespace_path %>
  class <%= operation_class_name %>Operation < <%= parent_operation_class %>
    def call
<% @steps.each do |step| -%>
      step_<%= step %>
<% end -%>
    end

    private

<% @steps.each do |step| -%>
    def step_<%= step %>
      # TODO: Implement <%= step %> step
      # Example:
      # - Load data: @data = Model.find(params[:id])
      # - Validate input: form.valid!
      # - Process data: @result = Service.process(@data)
      # - Return result: @result
    end

<% end -%>
  end
end
