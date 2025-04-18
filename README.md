# Rails HMVC

[![Gem Version](https://badge.fury.io/rb/rails_hmvc.svg)](https://badge.fury.io/rb/rails_hmvc)
[![Build Status](https://github.com/yourusername/rails_hmvc/workflows/CI/badge.svg)](https://github.com/yourusername/rails_hmvc/actions)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)

A Ruby gem that provides generators to establish an HMVC (Hierarchical Model-View-Controller) architecture in Rails applications. This gem helps create standardized components (controllers, operations, forms, serializers) following the HMVC pattern.

## Why Rails HMVC?

Rails is an excellent framework, but as projects grow, the standard MVC structure can become unwieldy. Controllers often become bloated with business logic, making code difficult to maintain and test.

Rails HMVC solves this by providing:

- **Clear Separation of Concerns**: Each component has a single responsibility
- **Consistent Structure**: Standardized directory organization
- **Easy Testing**: Isolated components are easier to test
- **Improved Maintainability**: Modular code is simpler to maintain
- **API Versioning**: Built-in support for API versioning

## Architecture

This gem establishes the following HMVC structure:

```
app/
├── controllers/   # Handle HTTP requests and responses
│   └── v1/
│       └── users_controller.rb
├── operations/    # Handle business logic
│   └── v1/users/
│       ├── index_operation.rb
│       └── ...
├── forms/         # Handle validation and data transformation
│   └── v1/users/
│       ├── create_form.rb
│       └── ...
├── models/        # ActiveRecord models and database logic
│   └── user.rb
└── serializers/   # Handle JSON serialization
    └── v1/
        └── user_serializer.rb

lib/
└── errors/        # Custom error classes
    ├── base_error.rb
    ├── api_error.rb
    └── resource_error.rb
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_hmvc'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install rails_hmvc
```

## Usage

### Initialize HMVC Structure

```bash
$ rails g hmvc:init
```

This creates the basic HMVC structure, base classes, and configuration file.

### Generate Full Resource

```bash
$ rails g hmvc:resources users
```

This generates:
- `app/controllers/v1/users_controller.rb`
- Operations in `app/operations/v1/users/`
- Forms in `app/forms/v1/users/`
- Serializer in `app/serializers/v1/user_serializer.rb`
- Route entries in `config/routes.rb`

### Generate Individual Components

#### Controller

```bash
$ rails g hmvc:controller users --actions=index,show,create,update,destroy
```

#### Operations

```bash
$ rails g hmvc:operation users/create --steps=validate,create_user,publish
```

#### Forms

```bash
$ rails g hmvc:form users/create --attributes name:string email:string --validations name:presence:true,email:presence:true,email:format:{with:/\A[^@\s]+@[^@\s]+\z/}
```

#### Serializers

```bash
$ rails g hmvc:serializer user --attributes id:integer name:string email:string
```

## Configuration

Rails HMVC uses a configuration file at `config/rails_hmvc.yml`:

```yaml
# Default project type: "api" or "web"
type: api

# Default parent classes
parent_controller: ApplicationController
parent_operation: ApplicationOperation
parent_form: ApplicationForm
parent_serializer: ApplicationSerializer

# Route generation behavior
skip_routes: false

# API versions
versions:
  - v1
  - v2
```

## CLI Options

All generators support these common options:

- `--version`: API version (default: v1)
- `--parent`: Parent class
- `--type`: Project type (api/web)

Plus specific options for each generator.

## Request Flow

A typical request flow with Rails HMVC:

1. **Controller** receives HTTP request
2. **Form** validates and transforms incoming data
3. **Operation** executes business logic using the validated data
4. **Serializer** formats the response data
5. **Controller** returns HTTP response

## Best Practices

- Keep controllers thin, delegating to operations
- Use forms for input validation and transformation
- Implement business logic in operations
- Break complex operations into small, focused steps
- Use serializers for consistent API responses

## Requirements

- Ruby >= 2.7.0
- Rails >= 6.1

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/rails_hmvc.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
