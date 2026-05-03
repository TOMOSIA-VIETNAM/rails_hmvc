# Rails HMVC

[![Gem Version](https://badge.fury.io/rb/rails_hmvc.svg)](https://badge.fury.io/rb/rails_hmvc)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)

**Your Rails controllers are doing too much.** Validation logic mixed with business rules. Database queries sitting next to HTTP responses. Fat models or fat controllers — pick your poison.

Rails HMVC fixes this by introducing two new layers — **Form** and **Operation** — between the controller and model, each with a single clear responsibility. One command generates the entire structure.

## The Problem

As Rails apps grow, MVC breaks down:

- **Controllers become dumping grounds** — validation, business logic, authorization, and response formatting all in one file
- **Models turn into god objects** — hundreds of lines mixing associations, scopes, callbacks, and business rules
- **No consistent structure** across the team — every developer organizes differently
- **Testing becomes painful** — you can't test business logic without booting the entire HTTP stack
- **API versioning is an afterthought** — breaking changes sneak into production

## The Solution

Rails HMVC enforces separation of concerns through **5 layers**, each doing exactly one thing:

| Layer | Responsibility |
|-------|---------------|
| **Controller** | HTTP only — receive request, return response |
| **Form** | Validate and transform input params |
| **Operation** | Execute business logic (the "what happens") |
| **Serializer** | Format JSON output |
| **Error** | Standardized error handling |

One generator creates everything:

```bash
rails g rails_hmvc:controller v1/users --type=api
```

This generates: 1 controller, 5 operations, 2 forms — all wired up, all following the same pattern.

## Quick Start

```ruby
# Gemfile
gem 'rails_hmvc'
```

```bash
bundle install

# Initialize HMVC structure
rails g rails_hmvc:init --type=api

# Generate your first resource
rails g rails_hmvc:controller v1/users --type=api
```

That's it. Your app now has:
- Base classes (`MainController`, `MainForm`, `MainOperation`, `MainSerializer`)
- Error handling (`Errorable` concern with standardized JSON errors)
- Render helpers (`render_collection`, `render_resource`)
- A versioned, structured component tree under `app/`

## How It Works

```
HTTP Request
    │
    ▼
Controller ──► Form (validate input)
    │              │
    │              ▼ raise Errors::ResourceError if invalid
    │
    └────────► Operation (business logic)
                   │
                   ▼
                 Model (database)
                   │
                   ▼
              Serializer (format JSON)
                   │
                   ▼
             HTTP Response
```

The controller never touches the database. Forms never run business logic. Operations never format responses. Each piece is testable in isolation.

## Requirements

- Ruby >= 2.7.0
- Rails >= 6.1.0

## Development

All development happens inside Docker — do not run Ruby on the host.

```bash
docker compose up -d                # start container (stays alive)
docker compose exec dev bash        # exec into container to work

# Inside container:
bundle exec rake                    # tests + rubocop (same as CI)
bundle exec rspec                   # tests only
COVERAGE=true bundle exec rspec     # 100% coverage check
gem build rails_hmvc.gemspec        # build .gem
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Documentation

| | English | Tiếng Việt | 日本語 |
|---|---------|------------|--------|
| Getting Started | [en](docs/en/getting-started.md) | [vi](docs/vi/getting-started.md) | [ja](docs/ja/getting-started.md) |
| Architecture | [en](docs/en/architecture.md) | [vi](docs/vi/architecture.md) | [ja](docs/ja/architecture.md) |
| Generators | [en](docs/en/generators.md) | [vi](docs/vi/generators.md) | [ja](docs/ja/generators.md) |
| Components | [en](docs/en/components.md) | [vi](docs/vi/components.md) | [ja](docs/ja/components.md) |
| Testing | [en](docs/en/testing.md) | [vi](docs/vi/testing.md) | [ja](docs/ja/testing.md) |

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
