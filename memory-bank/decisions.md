# Architectural and Implementation Decisions

## Core Architecture Decisions

### 1. Template-Based Generator Approach
- **Decision**: Sử dụng chỉ template-based generators thay vì cung cấp runtime classes
- **Rationale**:
  - Tránh xung đột namespace với Rails
  - Không can thiệp vào runtime của ứng dụng Rails
  - Cho phép dự án có thể tùy chỉnh mã nguồn sau khi generate
- **Impact**:
  - Gem cung cấp chỉ các generators mà không cần runtime dependencies
  - Dễ dàng tùy chỉnh và mở rộng

### 2. HMVC Structure
- **Decision**: Tổ chức theo cấu trúc Hierarchical MVC rõ ràng
- **Rationale**:
  - Tách biệt rõ ràng các thành phần
  - Cải thiện khả năng mở rộng
  - Các thành phần có thể được thay thế riêng lẻ
- **Components**:
  - Controllers: Xử lý HTTP requests và responses
  - Forms: Xử lý validation và data transformation
  - Operations: Xử lý business logic
  - Serializers: Xử lý data serialization

### 3. Versioning Approach
- **Decision**: Sử dụng versioning thông qua namespaces
- **Rationale**:
  - Cho phép nhiều phiên bản API tồn tại cùng lúc
  - Dễ dàng mở rộng và thêm phiên bản mới
- **Implementation**:
  - Các thành phần được tổ chức trong các namespace V1, V2, ...
  - Đường dẫn URL bao gồm version (/v1, /v2)

### 4. Error Handling
- **Decision**: Xử lý lỗi tập trung thông qua Errorable concern
- **Rationale**:
  - Đồng nhất cách xử lý lỗi
  - Cải thiện UX bằng cách cung cấp thông báo lỗi rõ ràng
- **Implementation**:
  - ResourceError for resource-specific errors
  - APIError for API-level errors
  - BaseError for generic errors

## Implementation Details

### 1. Generator Structure
- **Modular Generators**:
  - Mỗi generator có thể được sử dụng độc lập
  - Các generators có thể gọi lẫn nhau để tạo ra các components đầy đủ

- **Configuration Integration**:
  - Sử dụng rails_hmvc.yml để lưu trữ cấu hình
  - CLI options có thể ghi đè cấu hình từ file
  - Mỗi generator đều đọc cấu hình từ file này

- **Template-Based Generation**:
  - Mỗi component được sinh ra từ templates riêng biệt
  - Templates có thể được tùy chỉnh dễ dàng
  - ERB được sử dụng cho templates

### 2. Response Format
- **Standard Success Response**:
  ```json
  {
    "data": [ ... ],
    "meta": { ... },
    "status": "ok"
  }
  ```
- **Standard Error Response**:
  ```json
  {
    "error": "...",
    "message": "...",
    "errors": [ ... ],
    "status": "error"
  }
  ```

### 3. Component Guidelines
- **Controllers**:
  - Xử lý HTTP requests
  - Gọi operations cho business logic
  - Render responses sử dụng serializers

- **Forms**:
  - Validate input data
  - Transform data trước khi xử lý
  - Raise errors nếu validation thất bại

- **Operations**:
  - Xử lý business logic
  - Chia nhỏ logic thành các steps
  - Giao tiếp với database và external services

- **Serializers**:
  - Format data cho responses
  - Quản lý associations
  - Xử lý data transformation

## Future Considerations

### 1. Testing Support
- **Decision**: Thêm test templates và helpers
- **Rationale**: Giúp người dùng dễ dàng viết tests cho HMVC components
- **Planned Implementation**:
  - RSpec helpers
  - Test templates cho mỗi component
  - Integration test examples

### 2. Documentation Improvement
- **Decision**: Cung cấp documentation đầy đủ
- **Rationale**: Giúp người dùng hiểu và sử dụng gem hiệu quả
- **Planned Implementation**:
  - README.md comprehensive
  - Wiki pages for detailed guides
  - Examples for common use cases

### 3. CI/CD Implementation
- **Decision**: Thêm CI/CD workflows
- **Rationale**: Đảm bảo chất lượng code
- **Planned Implementation**:
  - GitHub Actions for testing
  - Automatic releases
  - Code quality checks

# Key Decisions and Technical Specifications

## CLI Command Simplification

### Current Status
- Commands currently use `rails g rails_hmvc:generator_name`
- This is verbose and redundant with "rails" appearing twice

### Decision
- Modify namespace from `rails g rails_hmvc:generator_name` to `rails g hmvc:generator_name`
- Keep gem name as `rails_hmvc` for clarity about its purpose

### Implementation Plan
- Update all generator registration to use the new namespace
- Consider adding deprecated aliases temporarily for backward compatibility
- Update all documentation to reflect new command format

## DRY Generator Templates

### Current Status
- Each generator has its own set of templates
- Significant code duplication across different generators
- Updates to templates require changes in multiple places

### Decision
- Create a centralized template system
- Use template helpers to share common code
- Implement a consistent naming and structure pattern

### Implementation Plan
- Create a shared templates directory
- Implement template inheritance mechanism
- Extract common code patterns into reusable helper methods
- Refactor all generators to use this new system

```ruby
# Example of refactored template loading
def template_directory
  File.expand_path('../templates', __FILE__)
end

def shared_template_directory
  File.expand_path('../../shared_templates', __FILE__)
end

def load_template(template_name, destination)
  template "#{shared_template_directory}/#{template_name}", destination
end
```

## Configuration System Improvements

### Current Status
- Configuration uses environment-specific settings (development, production, etc.)
- Limited support for type-specific configuration (api vs web)
- Uses api_version setting which is redundant with path-based namespace

### Decision
- Remove environment-specific config (development only for generators)
- Add robust type-specific configuration for api/web templates
- Support custom parent classes per project type
- Use path-based namespace generation instead of api_version setting

### Implementation Plan
- Update rails_hmvc.yml structure:

```yaml
# New configuration structure
type: api  # Default type (api or web)

# Type-specific configurations
types:
  api:
    parent_controller: ApplicationController
    parent_operation: ApplicationOperation
    parent_form: ApplicationForm
    parent_serializer: ApplicationSerializer
  web:
    parent_controller: WebController
    parent_operation: WebOperation
    parent_form: WebForm
    parent_serializer: WebSerializer

# Resource-specific configurations
resources:
  endpoints:
    index: true
    show: true
    create: true
    update: true
    destroy: true
  validations:
    create: true  # Generate validation in create form
    update: true  # Generate validation in update form

# General configurations
skip_routes: false
```

- Update the generator_helpers to parse this new structure
- Ensure backward compatibility with the old configuration format

## Template Content Enhancement

### Current Status
- Generated code lacks sufficient documentation
- No indication of relationships between components
- Limited comments in controller actions

### Decision
- Add route comments to controller actions
- Add docstring comments linking components together
- Improve overall code documentation

### Implementation Plan
- Update controller templates to include route comments:

```ruby
# Controller template example
<% actions.each do |action| %>
  # [<%= action_http_method(action) %>] <%= action_route_path(resource_name, action) %>
  def <%= action %>
    # Implementation
  end
<% end %>
```

- Update operation and form templates to include relationship docstrings:

```ruby
# Operation template example
# Operation for <%= action %> endpoint
# Used by: <%= controller_class %>#<%= action %>
# Form: <%= form_class if uses_form?(action) %>
class <%= class_name %> < <%= parent_class_name %>
  # Implementation
end
```

## Initialization Process Update

### Current Status
- Configuration is loaded directly in application.rb
- Potential for errors during Rails initialization
- Non-standard approach to configuration loading

### Decision
- Move configuration loading to config/initializers
- Add proper error handling
- Implement safer configuration approach

### Implementation Plan
- Create a Rails initializer template in the init generator:

```ruby
# config/initializers/rails_hmvc.rb
Rails.application.config.to_prepare do
  rails_hmvc_config = Rails.root.join('config', 'rails_hmvc.yml')
  if File.exist?(rails_hmvc_config)
    begin
      RailsHmvc.config = YAML.safe_load(File.read(rails_hmvc_config))
    rescue => e
      Rails.logger.error "Error loading rails_hmvc.yml: #{e.message}"
    end
  end
end
```

- Update the generator to create this file instead of modifying application.rb
- Provide a configuration accessor in the RailsHmvc module

## Resource-specific Configuration

### Current Status
- Limited configuration options for individual resources
- No way to customize which endpoints get generated
- No control over validation requirements

### Decision
- Implement resources-specific configuration in rails_hmvc.yml
- Allow customization of endpoints and validations
- Support custom resource options

### Implementation Plan
- Add resource configuration section to rails_hmvc.yml
- Update the resources generator to respect these settings
- Provide sensible defaults for missing configuration

## Form Nesting and Validation

### Current Status
- Limited support for nested form validation
- No clear convention for handling nested form objects

### Consideration
- Need to establish conventions for handling nested attributes
- Consider placing shared form validations in concerns directory

### Proposed Approach
- Maintain endpoint-based convention (Controller > Operation > Form)
- Support form composition through delegation rather than inheritance
- Place shared validators in concerns directory

```ruby
# Example of form with nested validation
class V1::Users::CreateForm < ApplicationForm
  attribute :name, :string
  attribute :email, :string
  attribute :profile, :hash

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  validate :validate_profile

  private

  def validate_profile
    profile_form = V1::Profiles::CreateForm.new(profile)
    unless profile_form.valid?
      profile_form.errors.each do |error|
        errors.add(:"profile.#{error.attribute}", error.message)
      end
    end
  end
end
```

## Extension Templates

### Current Status
- Limited to core HMVC components
- No support for common integrations

### Decision
- Plan for extension templates covering:
  - RSpec setup
  - JWT authorization
  - S3 integration
  - Slack notifications

### Implementation Plan
- Create a modular extension system
- Implement each extension as a separate generator
- Provide configuration options for each extension
