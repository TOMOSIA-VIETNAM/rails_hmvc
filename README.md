# Rails HMVC

[![Gem Version](https://badge.fury.io/rb/rails_hmvc.svg)](https://badge.fury.io/rb/rails_hmvc)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)

A Ruby gem that implements the HMVC (Hierarchical Model-View-Controller) architecture pattern for Rails applications through a set of generators. This gem helps create standardized components (controllers, operations, forms, serializers, views) with proper separation of concerns.

## Architecture Overview

The gem establishes the following HMVC structure:

```
app/
├── controllers/   # HTTP request/response handlers
│   └── v1/
│       └── users_controller.rb
├── operations/    # Business logic components
│   └── v1/users/
│       ├── index_operation.rb
│       └── ...
├── forms/         # Input validation and transformation
│   └── v1/users/
│       ├── create_form.rb
│       └── ...
├── views/         # View templates (for web projects)
│   └── v1/users/
│       ├── index.html.erb
│       ├── show.html.erb
│       └── _form.html.erb
└── serializers/   # Response formatting
    └── v1/
        └── user_serializer.rb

lib/
└── errors/        # Custom error handling
    ├── application_error.rb
    └── resource_error.rb
```

## Installation

Add to your application's Gemfile:

```ruby
gem 'rails_hmvc'
```

Then execute:

```bash
$ bundle install
```

## Usage

### Initialize HMVC Structure

Set up the basic HMVC architecture in your Rails application:

**For API projects:**
```bash
$ rails g rails_hmvc:init --type=api
```

**For Web projects (with views):**
```bash
$ rails g rails_hmvc:init --type=web
```

**Force views structure for API projects:**
```bash
$ rails g rails_hmvc:init --type=api --views
```

This creates:
- Base directory structure
- Parent classes for components
- Error handling classes
- Configuration files
- Views structure (layouts, shared) for web projects

### Generate Controllers

**API controllers:**
```bash
$ rails g rails_hmvc:controller v1/users --type=api
```

**Web controllers with views:**
```bash
$ rails g rails_hmvc:controller admin/products --type=web
$ rails g rails_hmvc:controller users --type=web --views
```

**Custom actions:**
```bash
$ rails g rails_hmvc:controller v1/auth --type=api --actions=login,register,logout
$ rails g rails_hmvc:controller admin/dashboard --type=web --actions=index,stats --views
```

**Skip components:**
```bash
$ rails g rails_hmvc:controller v1/products --type=api --skip_operation
$ rails g rails_hmvc:controller admin/categories --type=web --skip_form
$ rails g rails_hmvc:controller pages --type=web --skip_views
```

**Force views for API controllers:**
```bash
$ rails g rails_hmvc:controller api/debug --type=api --views
```

### Generate Operations

Create a single operation:

```bash
$ rails g rails_hmvc:operation v1/payments/process
```

Generate multiple operations:

```bash
$ rails g rails_hmvc:operation v1/orders --actions=approve,reject,ship
```

Add operation steps:

```bash
$ rails g rails_hmvc:operation v1/checkout/complete --steps=validate,process_payment,create_order
```

### Generate Forms

Create a form with attributes:

```bash
$ rails g rails_hmvc:form v1/auth/login --attributes=email:string,password:string
```

Generate multiple forms:

```bash
$ rails g rails_hmvc:form v1/products --actions=create,update --attributes=name:string,price:decimal
```

## Configuration

Rails HMVC uses a configuration file at `config/rails_hmvc.yml`:

```yaml
# Project type (api or web)
type: api

# API configuration
api:
  controllers:
    parent: MainController
    actions: [index, show, create, update, destroy]
  operations:
    parent: MainOperation
  forms:
    parent: MainForm
    actions: [create, update]

# Web configuration
web:
  controllers:
    parent: MainController
    actions: [index, show, new, edit, create, update, destroy]
  operations:
    parent: MainOperation
  forms:
    parent: MainForm
    actions: [create, update, new, edit]
  views:
    generate: true
    actions: [index, show, new, edit]
    partials: [form]
```

## Generator Options

### Common Options

- `--type`: Project type (api/web)
- `--parent`: Parent class name

### Init Generator Options

- `--views`: Force generate views structure (for any project type)

### Controller Generator Options

- `--actions`: List of controller actions
- `--skip_operation`: Skip generating operations
- `--skip_form`: Skip generating forms
- `--views`: Force generate views for the controller
- `--skip_views`: Skip generating views (even for web type)

### Operation Generator Options

- `--steps`: List of operation steps
- `--actions`: List of operations to generate

### Form Generator Options

- `--attributes`: List of form attributes (name:type format)
- `--actions`: List of forms to generate

### Views Features

Views are automatically generated for:
- `--type=web` projects (can be disabled with `--skip_views`)
- When `--views` option is explicitly used

Generated views include:
- Bootstrap 5 responsive design
- Form validation and error handling
- Navigation links between views
- Standard CRUD templates (index, show, new, edit, _form)

## Views Generation

Rails HMVC provides automatic view generation for web applications with the following features:

### When Views Are Generated

1. **Automatically for web projects:**
   ```bash
   rails g rails_hmvc:controller users --type=web
   ```

2. **Explicitly with --views option:**
   ```bash
   rails g rails_hmvc:controller api/debug --type=api --views
   ```

3. **Skipped with --skip-views:**
   ```bash
   rails g rails_hmvc:controller pages --type=web --skip-views
   ```

### Generated View Structure

For a controller like `admin/products`, views are generated at:
```
app/views/admin/products/
├── index.html.erb      # List all products
├── show.html.erb       # Show single product
├── new.html.erb        # New product form
├── edit.html.erb       # Edit product form
└── _form.html.erb      # Shared form partial
```

### View Features

- **Bootstrap 5 styling** with responsive design
- **Form validation** with error display
- **Navigation links** between related views
- **Dynamic routing** based on namespace
- **ERB templates** ready for customization

### Example Generated View

```erb
<!-- app/views/users/index.html.erb -->
<% content_for :title, "Users" %>

<div class="container">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h1>Users</h1>
    <%= link_to "New User", new_user_path, class: "btn btn-primary" %>
  </div>

  <div class="table-responsive">
    <table class="table table-striped">
      <!-- User listing with actions -->
    </table>
  </div>
</div>
```

## Component Workflows

### API Workflow

1. Controller receives HTTP request
2. Form validates input parameters
3. Operation executes business logic
4. Serializer formats the response
5. Controller returns HTTP response

### Web Workflow

1. Controller receives HTTP request
2. Form validates input parameters
3. Operation executes business logic
4. Controller renders view template

## Requirements

- Ruby >= 2.7.0
- Rails >= 6.1.0

## Development Setup

### API Project Setup

```bash
# Create test Rails application
rails new example_api --api
cd example_api

# Add the gem
bundle add rails_hmvc --path=../

# Generate initial structure
rails g rails_hmvc:init --type=api

# Test generators
rails g rails_hmvc:controller v1/users --type=api
rails g rails_hmvc:operation v1/users/activate
rails g rails_hmvc:form v1/users/create --attributes=name:string,email:string
```

### Web Project Setup

```bash
# Create test Rails application
rails new example_web
cd example_web

# Add the gem
bundle add rails_hmvc --path=../

# Generate initial structure with views
rails g rails_hmvc:init --type=web

# Test generators with views
rails g rails_hmvc:controller users --type=web
rails g rails_hmvc:controller admin/products --type=web --actions=index,show,approve
```

### Mixed Project (API with some web views)

```bash
# Create API project
rails new example_mixed --api
cd example_mixed

# Add the gem
bundle add rails_hmvc --path=../

# Generate initial structure
rails g rails_hmvc:init --type=api --views

# Generate API controllers
rails g rails_hmvc:controller api/v1/users --type=api

# Generate controllers with views for admin interface
rails g rails_hmvc:controller admin/dashboard --type=web --views
```

## Authors

Minh Tang <minh.tang1@tomosia.com>

Nguyen Anh <anh.nguyen1@tomosia.com>
