class <%= namespace_name %>::<%= operation_class_name %>Operation < <%= parent_operation_class %>
  def call
    step_validate
  end

  private

  def step_validate
    # TODO: Implement validation
  end
end
