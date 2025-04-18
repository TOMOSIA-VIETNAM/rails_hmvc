module <%= version.camelize %>
  class <%= class_name %>Serializer < <%= parent_serializer_class %>
    attributes :id, :created_at, :updated_at

    # Add additional attributes
    # attributes :name, :description

    # Add associations if needed
    # belongs_to :user
    # has_many :comments
  end
end
