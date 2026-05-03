# Components

How to implement each layer after generation. Every component has a single, explicit job — keep domain logic from leaking across boundaries.

## Controller

HTTP only: accept the request, run an Operation, return a response. No business logic, no direct database access.

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

    # GET /v1/users/:id
    def show
      operator = Users::ShowOperation.call(params:)
      render_resource(resource: operator.result, serializer: UserSerializer)
    end

    # POST /v1/users
    def create
      operator = Users::CreateOperation.call(params:)
      render_resource(resource: operator.result, serializer: UserSerializer, status: :created)
    end

    # PUT /v1/users/:id
    def update
      operator = Users::UpdateOperation.call(params:)
      render_resource(resource: operator.result, serializer: UserSerializer)
    end

    # DELETE /v1/users/:id
    def destroy
      Users::DestroyOperation.call(params:)
      head :no_content
    end
  end
end
```

**Render helpers** (from the `Renderable` concern):

| Method | When to use |
|--------|-------------|
| `render_collection(collection:, serializer:, meta:)` | Paginated or full `index` payloads |
| `render_resource(resource:, serializer:, status:)` | A single resource |
| `render_error(error, status)` | Manual error rendering |
| `head :no_content` | Successful `destroy` with no body |

**Conventions:**

- Subclass `MainController` or `ApiController`
- `wrap_parameters false` is set on `MainController`
- No direct ActiveRecord calls
- Do not rescue exceptions here — let `Errorable` normalize error responses

---

## Form

Validate and normalize input. Fail fast with a domain error when invalid. No persistence.

```ruby
# app/forms/v1/users/create_form.rb
# frozen_string_literal: true

class V1::Users::CreateForm < MainForm
  attribute :email,    :string
  attribute :password, :string
  attribute :name,     :string
  attribute :role,     :string, default: 'user'

  validates :email,    presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }
  validates :name,     presence: true
  validates :role,     inclusion: { in: %w[user admin] }
end
```

**Using a Form inside an Operation:**

```ruby
@form = V1::Users::CreateForm.new(params)
@form.valid!              # raises Errors::ResourceError when invalid
@form.attributes          # => { email: "...", password: "...", name: "...", role: "user" }
```

**Conventions:**

- Subclass `MainForm`
- Declare fields with `attribute :name, :type`
- Lean on standard `ActiveModel::Validations`
- `valid!` raises `Errors::ResourceError` on validation failure
- No database or outbound HTTP calls

---

## Operation

Encapsulates business logic. Public API is `call` only; split non-trivial flows into private `step_*` methods.

```ruby
# app/operations/v1/users/create_operation.rb
# frozen_string_literal: true

class V1::Users::CreateOperation < MainOperation
  def call
    step_validate
    step_create_user
    step_send_welcome_email
  end

  private

  def step_validate
    @form = V1::Users::CreateForm.new(params)
    @form.valid!
  end

  def step_create_user
    @result = User.create!(
      email:    @form.attributes[:email],
      password: @form.attributes[:password],
      name:     @form.attributes[:name],
      role:     @form.attributes[:role]
    )
  end

  def step_send_welcome_email
    UserMailer.welcome(@result).deliver_later
  end
end
```

**Passing `current_user` from the controller:**

```ruby
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
    @result = User.find(params[:id]).tap { |u| u.update!(@form.attributes) }
  end
end
```

```ruby
operator = Users::UpdateOperation.call(params: params.merge(current_user: current_user))
```

**Conventions:**

- Subclass `MainOperation`
- Single public method: `call`
- Keep implementation details in private `step_*` methods
- Assign `@result` so the controller can read `operator.result`
- Avoid rescuing exceptions — let them propagate to `Errorable`

---

## Serializer

Project records into JSON. Presentation only — no branching business rules.

```ruby
# app/serializers/v1/user_serializer.rb
# frozen_string_literal: true

class V1::UserSerializer < MainSerializer
  attributes :id, :email, :name, :role, :created_at

  has_many :posts, serializer: V1::PostSerializer
  belongs_to :organization, serializer: V1::OrganizationSerializer
end
```

**Conventions:**

- Subclass `MainSerializer`
- Limit surface area to `attributes` and association declarations
- Avoid complex conditionals or domain logic

---

## Error handling

`Errorable` on `MainController` maps exceptions to HTTP responses.

**Built-in rescues:**

| Exception | HTTP status |
|-----------|-------------|
| `StandardError` | 500 Internal Server Error |
| `ActiveRecord::RecordNotFound` | 404 Not Found |
| `ActiveRecord::RecordInvalid` | 422 Unprocessable Entity |
| `Errors::ResourceError` | 422 Unprocessable Entity |
| `Errors::APIError` | Status carried on the error object |

**Raising from Operations:**

```ruby
# Record missing
raise ActiveRecord::RecordNotFound, "User not found"

# Form validation (typically via valid!)
@form.valid!

# Arbitrary API failure with explicit status
raise Errors::APIError.new("Payment failed", status: 402, code: 'payment_failed')

# Resource-shaped validation payload
raise Errors::ResourceError.new(resource: user, message: user.errors.full_messages)
```

**Application-level errors** (from `lib/errors/application_error.rb`):

```ruby
# 404
raise NotFoundError, "User #{id} not found"

# 401
raise UnauthorizedError

# 403
raise ForbiddenError, "Insufficient permissions"
```
