---
name: rails-hmvc-rspec
description: Write RSpec unit tests for Rails HMVC components - operations, forms, controllers, serializers, and generators. Use when writing specs, adding test coverage, creating request specs, or testing HMVC generators.
---

# Rails HMVC RSpec Testing

## Spec Directory Mapping

Spec files mirror source paths:

| Source | Spec |
|--------|------|
| `app/controllers/v1/users_controller.rb` | `spec/requests/v1/users_spec.rb` |
| `app/operations/v1/users/create_operation.rb` | `spec/operations/v1/users/create_operation_spec.rb` |
| `app/forms/v1/users/create_form.rb` | `spec/forms/v1/users/create_form_spec.rb` |
| `app/serializers/v1/user_serializer.rb` | `spec/serializers/v1/user_serializer_spec.rb` |
| `lib/generators/hmvc/controller/controller_generator.rb` | `spec/generators/hmvc/controller_generator_spec.rb` |

## Component-Specific Patterns

### Operation

- Subject: `described_class.call(params:)` (uses class-level `.call`)
- Test through public `call` interface only, never call `step_` methods directly
- Verify side effects: DB changes, jobs, emails
- Error path: expect `Errors::ResourceError` from form validation

### Form

- Subject: `described_class.new(params)`
- Test each validation rule independently
- Test `valid!` raises `Errors::ResourceError` on invalid
- Test `attributes` returns symbolized hash
- NO DB interaction in form specs

### Controller (Request Spec)

- Use `type: :request`, not `type: :controller`
- Test HTTP status codes + response body
- Use `json_response` / `json_meta` helpers (from `spec/support/request_helpers.rb`)

### Generator

- Use `generator_spec` gem
- Setup: `prepare_destination` + write `config/rails_hmvc.yml` to destination
- Assert with `assert_file` (content check) and `assert_no_file`

```ruby
RSpec.describe RailsHmvc::Generators::ControllerGenerator, type: :generator do
  destination File.expand_path('../tmp', __dir__)

  before do
    prepare_destination
    FileUtils.mkdir_p(File.join(destination_root, 'config'))
    File.write(File.join(destination_root, 'config/rails_hmvc.yml'), YAML.dump(config))
  end

  let(:config) do
    {
      'type' => 'api',
      'api' => {
        'controllers' => { 'parent' => 'MainController', 'actions' => %w[index show create update destroy] },
        'operations' => { 'parent' => 'MainOperation' },
        'forms' => { 'parent' => 'MainForm', 'actions' => %w[create update] }
      }
    }
  end
end
```

## Multi-version Compatibility

This gem runs CI against **Ruby 2.7–3.3 × Rails 6.1–8.0** via Appraisals. When writing or editing specs:

- Do **not** use Ruby or Rails APIs newer than Ruby 2.7 / Rails 6.1 unless guarded by a version check.
- `spec/dummy/config/environments/test.rb` and `application.rb` use Rails-version conditionals — keep them compatible when changing the dummy app.
- Run against at least the default gemfile **and** one other Rails version before submitting:

```bash
bundle exec rspec                                  # default Gemfile
bundle exec appraisal rails-7-1 bundle exec rspec  # Rails 7.1
bundle exec appraisal rails-8-0 bundle exec rspec  # Rails 8.0
```

Supported matrix (excluded combos have comments in `.github/workflows/main.yml`):

| | Rails 6.1 | Rails 7.0 | Rails 7.1 | Rails 8.0 |
|-|-----------|-----------|-----------|-----------|
| Ruby 2.7 | ✓ | ✓ | ✓ | — |
| Ruby 3.0 | ✓ | ✓ | ✓ | — |
| Ruby 3.2 | — | ✓ | ✓ | ✓ |
| Ruby 3.3 | — | ✓ | ✓ | ✓ |

## Rules

1. Every component MUST have a corresponding spec file
2. Test both success and failure paths
3. Operation specs test through `call` only — never `step_` methods
4. Form specs MUST NOT touch the database
5. Controller specs are request specs (`type: :request`)
6. Each spec file tests ONE class
7. Use FactoryBot over fixtures
8. Specs must pass on **all supported Ruby × Rails combos** — avoid version-specific API usage
