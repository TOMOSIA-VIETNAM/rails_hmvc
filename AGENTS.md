# Agent Guide — Rails HMVC Gem

## What This Project Is

A Ruby gem that generates HMVC components (controllers, forms, operations, serializers) into host Rails apps. No application logic lives here — only generators, ERB templates, error classes, and a YAML config system.

## Project Structure

```
exe/
└── hmvc                       # CLI binary (hmvc init, hmvc g controller …)

lib/
├── rails_hmvc.rb              # Entrypoint, Railtie, generator registration
├── rails_hmvc/version.rb
├── errors/                    # Error classes shipped with gem
└── generators/hmvc/           # All generators + templates
    ├── generator_helpers.rb   # Shared config loading
    ├── init/                  # hmvc:init
    ├── controller/            # hmvc:controller (invokes operation + form)
    ├── form/                  # hmvc:form
    └── operation/             # hmvc:operation
```

## How It Works

1. `hmvc init --type=api` — scaffolds base classes + config (or `rails g hmvc:init`)
2. `hmvc g controller v1/users --type=api` — generates controller + operations + forms (or `rails g hmvc:controller`)
3. Defaults come from `config/rails_hmvc.yml`; CLI flags override
4. Legacy `rails g rails_hmvc:*` still works via fallback (prints no warning, delegates to `hmvc:*`)

## Development Environment

**All work runs inside Docker. Do NOT run commands on the host.**

```bash
docker compose up -d          # start container (keeps alive via bash)
docker compose exec dev bash  # exec in to work
```

Inside the container:

| Command | What it does |
|---------|-------------|
| `bundle exec rake` | RSpec then RuboCop (default CI task) |
| `bundle exec rspec` | Tests only |
| `bundle exec rspec` | Tests + SimpleCov (always prints coverage %) |
| `CI=true bundle exec rspec` | Same + enforces `minimum_coverage 100` |
| `gem build rails_hmvc.gemspec` | Build `.gem` artifact |

Source is mounted from host — edits reflect immediately without rebuild.

## Testing notes

- `spec/dummy/` is a minimal Rails app for booting Railtie in tests.
- `spec/rails_helper.rb` loads dummy env, calls `load_generators`, requires `lib/errors/*.rb`.
- Generator specs use `generator_spec` gem. Always pass full args to `run_generator` (the `arguments` macro is class-level, last writer wins).
- Templates (`lib/generators/**/templates/`) and `version.rb` are filtered from SimpleCov.

### Multi-version testing (Appraisals)

The gem targets **Ruby 2.7–3.3** × **Rails 6.1–8.0**. The `Appraisals` file at project root defines four variant Gemfiles; `bundle exec appraisal install` generates `gemfiles/*.gemfile` + lockfiles.

| Command | What it does |
|---------|-------------|
| `bundle exec appraisal install` | Resolve + lock deps for each Rails version |
| `bundle exec appraisal rails-7-1 bundle exec rspec` | Run specs under a specific Rails version |
| `bundle exec appraisal rails-8-0 bundle exec rake` | Full suite under Rails 8.0 |

**Supported matrix** (CI GitHub Actions):

| | Rails 6.1 | Rails 7.0 | Rails 7.1 | Rails 8.0 |
|-|-----------|-----------|-----------|-----------|
| Ruby 2.7 | ✓ | ✓ | ✓ | — |
| Ruby 3.0 | ✓ | ✓ | ✓ | — |
| Ruby 3.2 | — | ✓ | ✓ | ✓ |
| Ruby 3.3 | — | ✓ | ✓ | ✓ |

Excluded combos: Rails 8.0 requires Ruby ≥ 3.2; Rails 6.1 has Logger incompatibilities with Ruby ≥ 3.2.

`spec/dummy/config/environments/test.rb` and `application.rb` use version-conditional config to remain compatible across all supported Rails versions.

## HMVC Layers (What Gets Generated)

`Controller → Form → Operation → Model → Serializer → Response`

| Layer | Base Class | Location |
|-------|-----------|----------|
| Controller | `MainController` | `app/controllers/{version}/` |
| Form | `MainForm` | `app/forms/{version}/{resource}/` |
| Operation | `MainOperation` | `app/operations/{version}/{resource}/` |
| Serializer | `MainSerializer` | `app/serializers/{version}/` |
| Error | `ApplicationError` | `lib/errors/` |

## Documentation

Multilingual: `docs/en/` (primary), `docs/vi/`, `docs/ja/`. Update all three when changing user-facing behavior.
