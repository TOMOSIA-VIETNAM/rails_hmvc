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
rails g hmvc:init
```

### Resources Generator
Tạo đầy đủ các components cho một resource:
```bash
rails g hmvc:resources posts
```

### Form Generator
Tạo form object với validations:
```bash
rails g hmvc:form posts/create --attributes title:string content:text --validations title:presence:true
```

### Operation Generator
Tạo operation với custom steps:
```bash
rails g hmvc:operation posts/create --steps=validate,create_post,publish
```

### Controller Generator
Tạo controller với các actions:
```bash
rails g hmvc:controller posts --actions=index,show,create,update,destroy
```

### Serializer Generator
Tạo serializer cho model:
```bash
rails g hmvc:serializer post --attributes title:string content:text
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

# Technical Context: rails_hmvc Gem

## 1. CLI Commands

The gem provides command-line interface (CLI) tools for bootstrapping and generating resources. Commands read configuration from `config/rails_hmvc.yml`, but command-line arguments take precedence.

### 1.1. `rails g hmvc:init`

- **Purpose**: Initialize a project with the basic HMVC structure.
- **Functionality**: Creates `controllers/`, `operations/`, `forms/` directories and updates `application.rb` with HMVC configurations.

### 1.2. `rails g hmvc:resources`

- **Purpose**: Generate a complete set of RESTful resources (controller, operations, forms, routes).
- **Syntax**:
  ```sh
  rails g hmvc:resources \
    --resources=/v1/users \
    [--type=api|web] \
    [--parent-controller=ClassName] \
    [--parent-operation=ClassName] \
    [--parent-form=ClassName] \
    [--skip-routes=true|false]
  ```
- **Defaults**:
  - `--type`: Inherited from `application.rb` or `rails_hmvc.yml`.
  - `--skip-routes`: `false`.
- **Output**:
  - Adds namespace & resources to `config/routes.rb` (unless `--skip-routes=true`).
  - `app/controllers/v1/users_controller.rb`
  - `app/operations/v1/users/*_operation.rb` (5 files: index, show, create, update, destroy)
  - `app/forms/v1/users/*_form.rb` (corresponding files)

### 1.3. `rails g hmvc:operation`

- **Purpose**: Generate individual or RESTful groups of operations.
- **Syntax**:
  ```sh
  rails g hmvc:operation \
    --resources=/v1/users \
    [--resource=/v1/user/create] \
    [--type=api|web] \
    [--parent=ApplicationOperation]
  ```
- **Functionality**:
  - With `--resources`: Creates 5 operations (index, show, create, update, destroy).
  - With `--resource`: Creates only the specified operation file.
  - Inherits from the class specified by `--parent`.

### 1.4. `rails g hmvc:form`

- **Purpose**: Generate individual or RESTful groups of forms.
- **Syntax**:
  ```sh
  rails g hmvc:form \
    --resources=/v1/users \
    [--resource=/v1/user/create] \
    [--type=api|web] \
    [--parent=ApplicationForm]
  ```
- **Functionality**: Similar to the `operation` generator.

### 1.5. `rails g hmvc:controller`

- **Purpose**: Generate controller endpoints for a RESTful resource.
- **Syntax**:
  ```sh
  rails g hmvc:controller \
    --resources=/v1/users \
    [--type=api|web] \
    [--parent=ApplicationController]
  ```
- **Functionality**:
  - Generates `UsersController` with standard actions (`index, show, create, update, destroy`).
  - Inherits from the class specified by `--parent`.

---

## 2. Configuration (`config/rails_hmvc.yml`)

```yaml
# config/rails_hmvc.yml

# ─────────────────────────────────────────────────────────────────────────────
# General configuration for the rails_hmvc gem
# ─────────────────────────────────────────────────────────────────────────────

# Default project type: "api" or "web"
# (affects folder namespaces and generator templates)
type: api

# Default parent class for generated Controllers
# (e.g., ApplicationController, Api::BaseController)
parent_controller: ApplicationController

# Default parent class for generated Operations
# (e.g., ApplicationOperation)
parent_operation: ApplicationOperation

# Default parent class for generated Forms
# (e.g., ApplicationForm)
parent_form: ApplicationForm

# Default behavior for adding routes to config/routes.rb via CLI
# false = generate routes, true = skip route generation
skip_routes: false

# ─────────────────────────────────────────────────────────────────────────────
# Overrides per "type"
# ─────────────────────────────────────────────────────────────────────────────

types:
  api:
    parent_controller: ApplicationController # Example override
  web:
    parent_controller: ApplicationController # Example override

# ─────────────────────────────────────────────────────────────────────────────
# Additional configurations (e.g., default namespace version)
# ─────────────────────────────────────────────────────────────────────────────

# The first version in this list is used by default
# The CLI uses the first version for namespace generation if --resources is not passed
versions:
  - v1
  - v2
```
