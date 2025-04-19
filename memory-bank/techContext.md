# Technology Context

*[Outline the technologies, frameworks, and libraries used. Detail the development setup, including environment configurations and required tools. Note any technical constraints or dependencies that impact development.]*

# Technical Context

## Technologies

### Core
- **Ruby on Rails**: Framework chính, >= 6.1
- **Ruby**: >= 2.7.0
- **RSpec**: Testing framework
- **ActiveModel::Serializers**: Serialization
- **ERB**: Template engine cho generators

### Architecture
- **HMVC (Hierarchical MVC)**: Mô hình kiến trúc chính
- **Template-based Generator**: Không cung cấp runtime components
- **API-first Design**: Thiết kế hướng API

## Development Environment

### Setup
- **Bundle**: Quản lý dependencies
- **RSpec**: Viết tests
- **Rubocop**: Linting và code style
- **Example App**: Testing trong thư mục example/

## Gem Structure
```
rails_hmvc/
├── lib/
│   ├── rails_hmvc.rb                    # Entry point
│   ├── rails_hmvc/
│   │   └── version.rb                   # Version management
│   └── generators/                      # Generators
│       ├── generator_helpers.rb         # Shared helper methods
│       └── hmvc/
│           ├── init/                    # Init generator
│           ├── form/                    # Form generator
│           ├── operation/               # Operation generator
│           ├── controller/              # Controller generator
│           ├── serializer/              # Serializer generator
│           └── resources/               # Resources generator
├── spec/                                # Tests
├── example/                             # Example Rails app
└── Gemfile, rails_hmvc.gemspec          # Gem metadata
```

## How to Use Generators

### Init Generator
Khởi tạo cấu trúc HMVC cơ bản:
```bash
rails g rails_hmvc:init
```

### Resources Generator
Tạo đầy đủ các components cho một resource:
```bash
rails g rails_hmvc:resources posts
```

### Form Generator
Tạo form object với validations:
```bash
rails g rails_hmvc:form posts/create --attributes title:string content:text --validations title:presence:true
```

### Operation Generator
Tạo operation với custom steps:
```bash
rails g rails_hmvc:operation posts/create --steps=validate,create_post,publish
```

### Controller Generator
Tạo controller với các actions:
```bash
rails g rails_hmvc:controller posts --actions=index,show,create,update,destroy
```

### Serializer Generator
Tạo serializer cho model:
```bash
rails g rails_hmvc:serializer post --attributes title:string content:text
```

## Configuration

### rails_hmvc.yml
```yaml
development:
  type: api
  parent_controller: ApplicationController
  parent_operation: ApplicationOperation
  parent_form: ApplicationForm
  parent_serializer: ApplicationSerializer
  skip_routes: false
  api_version: v1
```

## CLI Options
Mỗi generator có các CLI options riêng, ví dụ:
- `--version`: API version (default: v1)
- `--parent`: Parent class
- `--attributes`: List of attributes
- `--validations`: List of validations

# Technical Context: Rails HMVC Gem Implementation

## 1. Main Module Structure

### 1.1 rails_hmvc.rb
Entry point của gem, chứa:
- Requires các dependencies chính
- Định nghĩa module RailsHmvc
- Đăng ký các generators với Rails

```ruby
# lib/rails_hmvc.rb
module RailsHmvc
  class Error < StandardError; end

  class Railtie < Rails::Railtie
    generators do
      require_relative "generators/hmvc/generator_helpers"
      require_relative "generators/hmvc/init/init_generator"
      require_relative "generators/hmvc/form/form_generator"
      require_relative "generators/hmvc/operation/operation_generator"
      require_relative "generators/hmvc/resources/resources_generator"
      require_relative "generators/hmvc/controller/controller_generator"
      require_relative "generators/hmvc/serializer/serializer_generator"
    end
  end if defined?(Rails::Railtie)
end
```

### 1.2 Generator Helpers
Module cung cấp các helper methods dùng chung cho tất cả các generators:

```ruby
# lib/generators/hmvc/generator_helpers.rb
module RailsHmvc
  module Generators
    module GeneratorHelpers
      def load_config
        config_path = File.join(destination_root, 'config/rails_hmvc.yml')
        return {} unless File.exist?(config_path)

        # Đọc và xử lý file YAML
      end

      def namespace_path
        class_path.join('/')
      end

      def namespace_name
        class_path.map(&:camelize).join('::')
      end

      def versioned_namespace?
        class_path.first&.match?(/^v\d+$/)
      end

      def resource_namespace?
        class_path.size > 1
      end
    end
  end
end
```

## 2. Generator Implementation Details

### 2.1 Init Generator
Tạo cấu trúc HMVC cơ bản và các base classes:

```ruby
# lib/generators/hmvc/init/init_generator.rb
module RailsHmvc
  module Generators
    class InitGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_hmvc_directories
        # Tạo các thư mục cần thiết
      end

      def create_configuration_file
        template 'config/rails_hmvc.yml.tt', 'config/rails_hmvc.yml'
      end

      def modify_application_rb
        # Thêm code vào application.rb
      end

      def create_base_error_class
        # Tạo các error classes
      end

      def create_base_classes
        # Tạo các base classes
      end

      def add_routes
        # Thêm routes
      end

      def create_concerns
        # Tạo các concerns
      end
    end
  end
end
```

### 2.2 Resources Generator
Tạo đầy đủ các components cho một resource bằng cách gọi các generator con:

```ruby
# lib/generators/hmvc/resources/resources_generator.rb
module RailsHmvc
  module Generators
    class ResourcesGenerator < Rails::Generators::NamedBase
      # Options và initialization

      def create_controller
        # Gọi controller generator
      end

      def create_operations
        # Gọi operation generator cho mỗi action
      end

      def create_forms
        # Gọi form generator cho các actions cần thiết
      end

      def create_serializer
        # Gọi serializer generator
      end

      def add_routes
        # Thêm routes
      end
    end
  end
end
```

### 2.3 Controller Generator
Tạo controller với các actions được chỉ định:

```ruby
# lib/generators/hmvc/controller/controller_generator.rb
module RailsHmvc
  module Generators
    class ControllerGenerator < Rails::Generators::NamedBase
      include GeneratorHelpers

      # Options và initialization

      def create_controller_file
        template('controller.rb', "app/controllers/#{controller_path}.rb")
      end

      # Helper methods
    end
  end
end
```

Controller template:
```ruby
# lib/generators/hmvc/controller/templates/controller.rb
class <%= controller_class_name %> < <%= parent_controller_class %>
  def <%= action %>
    result = <%= operation_class_for(action) %>.call(<%= params_method %>)
    render_resource(resource: result, serializer: <%= serializer_class %>)
  end

  # Other actions and private methods
end
```

### 2.4 Operation Generator
Tạo operation với các steps được chỉ định:

```ruby
# lib/generators/hmvc/operation/templates/operation.rb
module <%= namespace_path %>
  class <%= operation_class_name %>Operation < <%= parent_operation_class %>
    def call
      <% @steps.each do |step| %>
      step_<%= step %>
      <% end %>
    end

    private

    <% @steps.each do |step| %>
    def step_<%= step %>
      # TODO: Implement <%= step %> step
    end
    <% end %>
  end
end
```

### 2.5 Form Generator
Tạo form với các attributes và validations:

```ruby
# lib/generators/hmvc/form/templates/form.rb
class <%= namespaced_class_name %> < MainForm
  # Define form attributes
  <%= attribute_definitions %>

  # Define validations
  <%= validation_definitions %>

  # Other methods
end
```

### 2.6 Serializer Generator
Tạo serializer với các attributes và associations:

```ruby
# lib/generators/hmvc/serializer/templates/serializer.rb
class <%= serializer_class_name %> < <%= parent_serializer_class %>
  attributes <%= attributes_list.map { |attr| ":#{attr}" }.join(', ') %>

  <% associations[:belongs_to].each do |assoc| %>
  belongs_to :<%= assoc %>
  <% end %>

  # Other associations
end
```

## 3. Template System

Mỗi generator có template riêng, được lưu trong thư mục `/templates`:

- **Controller Templates**: Chứa template cho controller
- **Operation Templates**: Chứa template cho operation
- **Form Templates**: Chứa template cho form
- **Serializer Templates**: Chứa template cho serializer
- **Error Templates**: Chứa template cho error classes
- **Concern Templates**: Chứa template cho các concerns như Renderable, Errorable

## 4. Configuration Logic

File cấu hình `rails_hmvc.yml` được đọc bởi method `load_config` trong module `GeneratorHelpers`:

```ruby
def load_config
  config_path = File.join(destination_root, 'config/rails_hmvc.yml')
  return {} unless File.exist?(config_path)

  env = defined?(Rails.env) ? Rails.env : 'development'

  # Đọc và xử lý YAML
  # Trả về config[env] hoặc {}
end
```

Configuration được sử dụng để thiết lập defaults cho các generators.
