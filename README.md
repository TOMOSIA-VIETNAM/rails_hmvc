# Rails HMVC

[![Gem Version](https://badge.fury.io/rb/rails_hmvc.svg)](https://badge.fury.io/rb/rails_hmvc)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)

A Ruby gem that implements the HMVC (Hierarchical Model-View-Controller) architecture pattern for Rails applications through a set of generators. This gem helps create standardized components (controllers, operations, forms, serializers, views) with proper separation of concerns and includes custom RuboCop cops to enforce architectural conventions.

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
- `--routes`: Generate routes automatically
- `--skip_routes`: Skip route generation
- `--resource-routes`: Use resource routes (default: true)
- `--no-resource-routes`: Use individual routes

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

## Routes Generation

Rails HMVC provides automatic route generation for controllers with the following features:

### When Routes Are Generated

1. **Explicitly with --routes option:**
   ```bash
   rails g rails_hmvc:controller products --type=web --routes
   # Generates: resources :products
   ```

2. **Auto-generated based on config:**
   ```yaml
   # rails_hmvc.yml
   web:
     routes:
       generate: true
       resource_routes: true
   ```

3. **Skipped with --skip-routes:**
   ```bash
   rails g rails_hmvc:controller articles --routes --skip-routes
   ```

### Route Types

#### **Resource Routes (Default)**
```bash
rails g rails_hmvc:controller products --routes
```
Generated:
```ruby
resources :products
```

#### **Namespaced Routes**
```bash
rails g rails_hmvc:controller api/v1/users --type=api --routes
```
Generated:
```ruby
namespace :api do
  namespace :v1 do
    resources :users, only: ["index", "show", "create", "update", "destroy"]
  end
end
```

#### **Individual Routes**
```bash
rails g rails_hmvc:controller books --actions=index,show,search --routes --no-resource-routes
```
Generated:
```ruby
get 'books', to: 'books#index'
get 'books/:id', to: 'books#show'
get 'books/:id/search', to: 'books#search'
```

### Route Options

- `--routes`: Enable route generation
- `--skip-routes`: Skip route generation
- `--resource-routes`: Use resource routes (default: true)
- `--no-resource-routes`: Use individual routes

### Configuration

```yaml
# config/rails_hmvc.yml
api:
  routes:
    generate: true          # Auto-generate routes
    resource_routes: true   # Use resource routes

web:
  routes:
    generate: true          # Auto-generate routes
    resource_routes: true   # Use resource routes
```

### Examples

**Standard Web Controller:**
```bash
rails g rails_hmvc:controller posts --type=web --routes
# Creates: resources :posts
```

**API with Limited Actions:**
```bash
rails g rails_hmvc:controller api/articles --actions=index,show --routes
# Creates: namespace :api do resources :articles, only: ["index", "show"] end
```

**Custom Actions:**
```bash
rails g rails_hmvc:controller reports --actions=index,generate,download --routes
# Creates individual routes for each action
```

## RuboCop Integration

Rails HMVC includes custom RuboCop cops to enforce architectural conventions and maintain code quality.

### Setup RuboCop Configuration

**Option 1: Auto-generate configuration (Recommended)**

```bash
# Generate optimized .rubocop.yml for Rails HMVC
rails g rails_hmvc:rubocop

# Or force overwrite existing config
rails g rails_hmvc:rubocop --force

# Important: Update TargetRubyVersion to match your Ruby version
# Edit .rubocop.yml and set: TargetRubyVersion: 3.2 (for Ruby 3.2.x)
```

**Option 2: Manual setup**

Add to your `.rubocop.yml`:

```yaml
require:
  - rails_hmvc

plugins:
  - rubocop-rails
  - rubocop-rspec

AllCops:
  TargetRubyVersion: 3.2  # Update to match your Ruby version
  NewCops: enable

# Enable HMVC cops
RailsHmvc/Operations/CallMethod:
  Enabled: true
  Include:
    - 'app/operations/**/*_operation.rb'

RailsHmvc/Operations/StepMethods:
  Enabled: true
  Include:
    - 'app/operations/**/*_operation.rb'

RailsHmvc/Forms/ValidationOnly:
  Enabled: true
  Include:
    - 'app/forms/**/*_form.rb'

RailsHmvc/Controllers/NoBusinessLogic:
  Enabled: true
  Include:
    - 'app/controllers/**/*_controller.rb'
```

**Install required gems:**

```bash
bundle add rubocop-rails rubocop-rspec --group development
```

### Available Cops

- **Operations/CallMethod**: Ensures operations have a `call` method
- **Operations/StepMethods**: Enforces step method pattern in operations
- **Operations/BusinessLogicOnly**: Prevents direct model calls in `call` method
- **Forms/ValidationOnly**: Ensures forms only contain validation logic
- **Forms/NoDatabaseInteraction**: Prevents database calls in forms
- **Controllers/NoBusinessLogic**: Prevents business logic in controllers
- **Controllers/DelegateToOperations**: Enforces operation delegation
- **Models/ConcernsLocation**: Suggests moving complex logic to concerns

### Usage

**Basic Commands:**

```bash
# Run ALL RuboCop cops (including HMVC)
bundle exec rubocop

# Run ALL HMVC cops (all departments)
bundle exec rubocop --only RailsHmvc/Operations,RailsHmvc/Forms,RailsHmvc/Controllers,RailsHmvc/Models

# Use shortcut script (if available)
./bin/rubocop-hmvc

# Run specific HMVC departments
bundle exec rubocop --only RailsHmvc/Operations
bundle exec rubocop --only RailsHmvc/Forms
bundle exec rubocop --only RailsHmvc/Controllers

# Run specific individual cops
bundle exec rubocop --only RailsHmvc/Operations/CallMethod
bundle exec rubocop --only RailsHmvc/Forms/ValidationOnly
```

**Auto-Fix Commands:**

```bash
# Safe auto-fix for all cops
bundle exec rubocop --safe-auto-correct

# Auto-fix only HMVC violations (all departments)
bundle exec rubocop --only RailsHmvc/Operations,RailsHmvc/Forms,RailsHmvc/Controllers,RailsHmvc/Models --safe-auto-correct

# Use shortcut script with auto-fix
./bin/rubocop-hmvc --safe-auto-correct

# Auto-fix specific departments
bundle exec rubocop --only RailsHmvc/Operations --safe-auto-correct
```

**Development Workflow:**

```bash
# Quick check specific files
bundle exec rubocop --only RailsHmvc/Operations app/operations/user/create_operation.rb

# Check all operations directory
bundle exec rubocop --only RailsHmvc/Operations app/operations/

# Pre-commit check (recommended) - all HMVC violations
./bin/rubocop-hmvc app/

# Check multiple departments
bundle exec rubocop --only RailsHmvc/Operations,RailsHmvc/Forms app/
```

**Configuration Notes:**

- Ensure `TargetRubyVersion` matches your Ruby version (e.g., `3.2` for Ruby 3.2.x)
- Department pattern `--only RailsHmvc` is **not supported** (RuboCop limitation)
- Use department list for all HMVC cops: `RailsHmvc/Operations,RailsHmvc/Forms,RailsHmvc/Controllers,RailsHmvc/Models`
- Individual department patterns work: `--only RailsHmvc/Operations`

### Troubleshooting

**Common Issues:**

1. **"Unrecognized cop or department: RailsHmvc"**
   ```bash
   # Check if gem is loaded
   bundle exec gem list | grep rails_hmvc

   # Verify require path in .rubocop.yml
   require:
     - rails_hmvc  # NOT ./lib/rubocop-rails-hmvc
   ```

2. **"Unexpected token" syntax errors**
   ```bash
   # Update Ruby version in .rubocop.yml
   AllCops:
     TargetRubyVersion: 3.2  # Match your Ruby version
   ```

3. **Department `--only RailsHmvc` doesn't work**
   ```bash
   # Use department list instead
   bundle exec rubocop --only RailsHmvc/Operations,RailsHmvc/Forms,RailsHmvc/Controllers,RailsHmvc/Models

   # Or use shortcut script
   ./bin/rubocop-hmvc
   ```

4. **Debug cops loading**
   ```ruby
   # Create debug script
   require 'rubocop'
   require 'rails_hmvc'

   registry = RuboCop::Cop::Registry.global
   hmvc_cops = registry.cops.select { |cop| cop.cop_name.start_with?('RailsHmvc') }
   puts "Found #{hmvc_cops.count} HMVC cops"
   hmvc_cops.each { |cop| puts "- #{cop.cop_name}" }
   ```

See [RUBOCOP_HMVC.md](RUBOCOP_HMVC.md) for detailed documentation.

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
