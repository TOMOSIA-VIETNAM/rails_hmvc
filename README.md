# Rails HMVC

[![Gem Version](https://badge.fury.io/rb/rails_hmvc.svg)](https://badge.fury.io/rb/rails_hmvc)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)

A Ruby gem that implements the HMVC (Hierarchical Model-View-Controller) architecture pattern for Rails applications through a set of generators. This gem helps create standardized components (controllers, operations, forms, serializers) with proper separation of concerns.

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

```bash
$ rails g rails_hmvc:init --type=api
```

This creates:
- Base directory structure
- Parent classes for components
- Error handling classes
- Configuration files

### Generate Controllers

Create a controller with default REST actions:

```bash
$ rails g rails_hmvc:controller v1/users --type=api
```

With specific actions:

```bash
$ rails g rails_hmvc:controller v1/auth --type=api --actions=login,register,logout
```

Skip associated operations or forms:

```bash
$ rails g rails_hmvc:controller v1/products --type=api --skip_operation
$ rails g rails_hmvc:controller v1/categories --type=api --skip_form
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

# Parent classes
controllers:
  parent: MainController
  actions: [index, show, create, update, destroy]

operations:
  parent: MainOperation
  steps: [validate, execute]

forms:
  parent: MainForm
  actions: [create, update]
```

## Generator Options

Common options for all generators:

- `--type`: Project type (api/web)
- `--parent`: Parent class name

Controller-specific options:
- `--actions`: List of controller actions
- `--skip_operation`: Skip generating operations
- `--skip_form`: Skip generating forms

Operation-specific options:
- `--steps`: List of operation steps
- `--actions`: List of operations to generate

Form-specific options:
- `--attributes`: List of form attributes (name:type format)
- `--actions`: List of forms to generate

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

To set up for development:

```bash
# Create test Rails application
rails new example --api
cd example

# Add the gem
bundle add rails_hmvc --path=../

# Generate initial structure
rails g rails_hmvc:init --type=api

# Test generators
rails g rails_hmvc:controller v1/users --type=api
```

## Authors

Minh Tang <minh.tang1@tomosia.com>

Nguyen Anh <anh.nguyen1@tomosia.com>
