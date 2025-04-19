module <%= version.camelize %>
  module <%= class_name.pluralize %>
    class CreateForm < <%= parent_form_class %>
      # Define attributes
      # attribute :name, :string
      # attribute :description, :text
      # ...

      # Add validations
      # validates :name, presence: true
      # validates :description, length: { maximum: 1000 }
      # ...
    end
  end
end
