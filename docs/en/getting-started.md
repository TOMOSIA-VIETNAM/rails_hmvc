# Getting Started

> Stand up the HMVC layout in your Rails app in about five minutes.

## Requirements

- Ruby >= 2.7.0
- Rails >= 6.1.0

## 1. Install the gem

Add to your `Gemfile`:

```ruby
gem 'rails_hmvc'
```

Then run:

```bash
bundle install
```

## 2. Initialize the HMVC structure

```bash
rails g hmvc:init --type=api
# or shorter: hmvc init --type=api
```

This scaffolds the directory tree, base classes, concerns, and configuration:

```
app/
├── controllers/
│   ├── main_controller.rb        # Base controller
│   ├── api_controller.rb         # API base controller
│   └── concerns/
│       ├── renderable.rb         # render_collection, render_resource helpers
│       └── errorable.rb          # rescue_from error handlers
├── forms/
│   └── main_form.rb              # Base form (ActiveModel::Model + Attributes)
├── operations/
│   └── main_operation.rb         # Base operation
└── serializers/
    ├── main_serializer.rb
    └── error_serializer.rb

lib/errors/
├── application_error.rb          # Base error classes
└── resource_error.rb

config/
└── rails_hmvc.yml                # Generator defaults
```

> For a classic web app: `rails g hmvc:init --type=web`

## 3. Generate your first resource

```bash
rails g hmvc:controller v1/users --type=api
# or shorter: hmvc g controller v1/users --type=api
```

To undo the generation, use `rails d` with the same arguments:

```bash
rails d hmvc:controller v1/users --type=api
```

Generated artifacts:

```
app/controllers/v1/users_controller.rb
app/operations/v1/users/index_operation.rb
app/operations/v1/users/show_operation.rb
app/operations/v1/users/create_operation.rb
app/operations/v1/users/update_operation.rb
app/operations/v1/users/destroy_operation.rb
app/forms/v1/users/create_form.rb
app/forms/v1/users/update_form.rb
```

## 4. Wire up routes

```ruby
# config/routes.rb
namespace :v1 do
  resources :users
end
```

## 5. Implement your domain logic

Open each generated file and fill in behavior:

- **Controller** (`app/controllers/v1/users_controller.rb`) — delegate to Operations and render responses only
- **Form** (`app/forms/v1/users/create_form.rb`) — declare attributes and validations
- **Operation** (`app/operations/v1/users/create_operation.rb`) — implement business rules in `step_*` methods

See [components.md](components.md) for layer-by-layer conventions.

## Next steps

- [architecture.md](architecture.md) — How HMVC fits together
- [generators.md](generators.md) — Generator options and flags
- [components.md](components.md) — Patterns for controllers, operations, forms, and serializers
