---
description: Specification for Rails HMVC operations
globs:
  - "app/operations/**/*.rb"
alwaysApply: true
---

# Operation Specification

The key words MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY are normative.

An Operation holds all business logic for one use case. It is the only layer that
reads/writes models and produces side effects.

## 1. Definition & Location

1.1. An Operation MUST live under `app/operations/{version}/{resource}/`.
     Example: `app/operations/v1/users/create_operation.rb`.

1.2. The class MUST be namespaced and named `{Action}Operation`.
     Example: `class V1::Users::CreateOperation < MainOperation`.

1.3. An Operation MUST subclass `MainOperation`.

## 2. The `call` Contract

2.1. `MainOperation.call(params:)` MUST be the only entry point. It instantiates
     the Operation, runs `#call`, and returns the instance ("operator"):
```ruby
class << self
  def call(*args)
    itself = new(*args)
    itself.call
    itself
  end
end
```

2.2. An Operation MUST implement the instance method `call` as its only public
     method. All other methods MUST be `private`.

2.3. `initialize` is provided by `MainOperation`. It sets `@params` and
     `@current_user = params[:current_user]`. Subclasses SHOULD NOT override
     `initialize`; read context via `params` and `current_user`.

## 3. Steps

3.1. Non-trivial `call` MUST be decomposed into private `step_*` methods, invoked
     in order from `call`:
```ruby
def call
  step_validate
  step_create_user
  step_send_welcome_email
end
```

3.2. Each `step_*` method SHOULD do one thing. Steps communicate through
     instance variables (`@form`, `@result`, …), not return values.

3.3. Validation MUST be a step that instantiates the Form and calls `valid!`:
```ruby
def step_validate
  @form = V1::Users::CreateForm.new(params)
  @form.valid!
end
```

## 4. Result Contract

4.1. An Operation MUST assign `@result` so the controller can read
     `operator.result`. `result` is the use case's output (a record, a
     collection, etc.).

4.2. Persistence MUST use the Form's trusted attributes, never raw params:
```ruby
def step_create_user
  @result = User.create!(**@form.attributes)
end
```

4.3. `MainOperation` exposes `success?`/`error?` derived from `errors` (which
     defaults to `@form.errors`). Operations MAY rely on this for web flows
     (`if operator.success?`).

## 5. Responsibilities

5.1. An Operation MUST own:
     - all business rules and decisions,
     - all model reads/writes,
     - transactions (`ActiveRecord::Base.transaction`),
     - calls to external services, mailers, jobs.

5.2. An Operation MUST NOT touch HTTP: no `request`, no `render`, no status codes.

5.3. An Operation MUST NOT know about controllers or serializers.

5.4. An Operation MUST NOT build response JSON.

## 6. Authorization & Errors

6.1. Domain authorization belongs in an Operation step, raising an API error:
```ruby
def step_authorize
  raise Errors::APIError.new('Forbidden', status: 403) unless current_user.admin?
end
```

6.2. An Operation MUST NOT rescue exceptions for the purpose of producing an HTTP
     response. Let errors propagate to `Errorable`. Raise:
     - `ActiveRecord::RecordNotFound` for missing records,
     - `Errors::ResourceError` (usually via `Form#valid!`) for invalid input,
     - `Errors::APIError.new(msg, status:, code:)` for explicit failures.

6.3. An Operation MAY rescue only to translate a low-level error into a domain
     error (re-raising), never to swallow it.

## 7. Transactions

7.1. Multi-write use cases MUST wrap mutations in a transaction so failure rolls
     back cleanly:
```ruby
def step_persist
  ActiveRecord::Base.transaction do
    @result = Order.create!(**@form.attributes)
    @result.line_items.create!(...)
  end
end
```

## 8. Canonical Example

```ruby
# app/operations/v1/users/update_operation.rb
# frozen_string_literal: true

class V1::Users::UpdateOperation < MainOperation
  def call
    step_authorize
    step_validate
    step_update
  end

  private

  def step_authorize
    raise Errors::APIError.new('Forbidden', status: 403) unless current_user.admin?
  end

  def step_validate
    @form = V1::Users::UpdateForm.new(params)
    @form.valid!
  end

  def step_update
    @result = User.find(params[:id]).tap { |u| u.update!(**@form.attributes) }
  end
end
```

Invoked with merged context:
```ruby
operator = Users::UpdateOperation.call(params: params.merge(current_user:))
```

## 9. Generation

```
hmvc g operation v1/user --actions=index,create,update --steps=validate,persist
```
Generates one `{Action}Operation` per action with stubbed `step_*` methods.
