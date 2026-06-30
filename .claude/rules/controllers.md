---
description: Specification for Rails HMVC controllers
globs:
  - "app/controllers/**/*.rb"
alwaysApply: true
---

# Controller Specification

The key words MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY are normative.

A Controller is the HTTP boundary. It accepts a request, delegates work to an
Operation, and renders a response. Nothing else.

## 1. Definition & Location

1.1. A controller MUST live under `app/controllers/{version}/`.
     Example: `app/controllers/v1/users_controller.rb`.

1.2. The class MUST be namespaced by version and named `{Resource}Controller`.
     Example: `module V1; class UsersController < MainController; end; end`.

1.3. A controller MUST subclass `MainController` or `ApiController`.
     `ApiController` SHOULD be used for JSON APIs (it forces `:json` format).

1.4. `MainController` already includes `Renderable` and `Errorable`. A controller
     MUST NOT re-include them.

## 2. Responsibilities

2.1. A controller MUST limit itself to:
     - reading params and request context,
     - invoking exactly one Operation per action via `.call(params:)`,
     - rendering via `Renderable` helpers,
     - returning HTTP status codes.

2.2. A controller MUST NOT contain business logic.

2.3. A controller MUST NOT call ActiveRecord directly (no `Model.find`,
     `.where`, `.create`, etc.). Persistence belongs to the Operation.

2.4. A controller MUST NOT validate input. Validation belongs to the Form.

2.5. A controller MUST NOT build JSON by hand. Shaping belongs to the Serializer.

2.6. A controller MUST NOT instantiate a Form directly. The Operation owns Form
     usage. The controller only knows the Operation.

## 3. Invoking Operations

3.1. Each action MUST call its Operation with the class method `call`, passing
     `params:`:
```ruby
operator = Users::CreateOperation.call(params:)
```

3.2. `.call` returns the Operation instance (the "operator"). The controller
     reads results from `operator.result` and state from `operator.success?` /
     `operator.error?`.

3.3. When the Operation needs the authenticated user, the controller MUST merge
     it into params:
```ruby
operator = Users::UpdateOperation.call(params: params.merge(current_user:))
```

3.4. One action MUST map to one Operation. Do not orchestrate multiple
     Operations inside an action; compose them inside a single Operation.

## 4. Rendering

4.1. Collections (e.g. `index`) MUST use `render_collection`:
```ruby
render_collection(
  collection: operator.result,
  serializer: UserSerializer,
  meta: pagination_meta(operator.result)
)
```

4.2. A single resource MUST use `render_resource`:
```ruby
render_resource(resource: operator.result, serializer: UserSerializer)
```

4.3. `create` MUST render with `status: :created`.

4.4. `destroy` with no body MUST respond `head :no_content`.

4.5. `render_error` MAY be used for explicit manual error rendering, but is
     rarely needed — see §5.

4.6. Every render of a resource or collection MUST pass an explicit `serializer:`.

## 5. Error Handling

5.1. A controller MUST NOT `rescue` exceptions. `Errorable` (on `MainController`)
     centralizes error-to-HTTP mapping via `rescue_from`.

5.2. Errors MUST propagate from the Operation/Form and be normalized by
     `Errorable`. Mapping:

| Exception                       | Status |
|---------------------------------|--------|
| `ActiveRecord::RecordNotFound`  | 404    |
| `ActiveRecord::RecordInvalid`   | 422    |
| `Errors::ResourceError`         | 422    |
| `Errors::APIError`              | error's `status` |
| `StandardError`                 | 500    |

5.3. A controller MUST NOT define a bespoke JSON error shape. Use the standard
     `Errorable` responses unless the user explicitly requests otherwise.

## 6. Filters & Auth

6.1. Cross-cutting concerns (authentication, locale, etc.) SHOULD use
     `before_action`.
```ruby
before_action :authenticate_user!
```

6.2. `before_action` MUST NOT carry business rules. Authorization that depends on
     domain state belongs in the Operation (raise `Errors::APIError` with status
     403).

## 7. Canonical Example

```ruby
# app/controllers/v1/users_controller.rb
# frozen_string_literal: true

module V1
  class UsersController < MainController
    before_action :authenticate_user!

    # GET /v1/users
    def index
      operator = Users::IndexOperation.call(params:)
      render_collection(
        collection: operator.result,
        serializer: UserSerializer,
        meta: pagination_meta(operator.result)
      )
    end

    # POST /v1/users
    def create
      operator = Users::CreateOperation.call(params:)
      render_resource(resource: operator.result, serializer: UserSerializer, status: :created)
    end

    # DELETE /v1/users/:id
    def destroy
      Users::DestroyOperation.call(params:)
      head :no_content
    end
  end
end
```

## 8. Generation

8.1. Prefer the generator over hand-writing:
```
hmvc g controller v1/user
```
It produces the controller, Operations, and Forms wired to config defaults
(`config/rails_hmvc.yml`). Actions and parents come from that config.
