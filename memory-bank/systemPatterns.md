# System Patterns: rails_hmvc Gem

## 1. HMVC Architecture

The architecture emphasizes clear separation of responsibilities:

| Layer       | Primary Responsibility                                 |
|-------------|--------------------------------------------------------|
| **Controller** | Handles routing, receives requests, returns responses; Only calls Operations, contains no business logic |
| **Operation**  | Orchestrates business logic through steps (`step_*`); Exposes only the `call` method      |
| **Form**       | Validates input parameters; Does not interact with the DB |
| **Model**      | Declares relationships, scopes, enums, persistence; Extended logic is placed in concerns   |
| **Error Layer**| Manages exceptions, renders standardized errors          |

---

## 2. Standard Directory Structure

```
app/
├── controllers/   # Controllers namespaced by version
│   └── v1/
│       └── users_controller.rb
├── operations/    # Business logic
│   └── v1/users/
│       ├── index_operation.rb
│       ├── show_operation.rb
│       ├── create_operation.rb
│       ├── update_operation.rb
│       └── destroy_operation.rb
├── forms/         # Validation
│   └── v1/users/
│       ├── index_form.rb
│       ├── show_form.rb
│       ├── create_form.rb
│       ├── update_form.rb
│       └── destroy_form.rb
├── models/        # ActiveRecord / Mongoid models
│   └── user.rb
lib/
└── errors/        # Custom error classes
    ├── application_error.rb
    ├── not_found_error.rb
    └── unauthorized_error.rb
```

---

## 3. Detailed Layer Conventions

### 3.1. Controller

- **Only calls Operations**:
  ```ruby
  op = V1::Users::CreateOperation.new(params, current_member: current_member)
  op.call
  render_json(op.result)
  ```
- **No business logic**: Avoid using `.save`, `.update`, etc.
- **Callbacks allowed** (e.g., `before_action :authenticate_user!`).

### 3.2. Operation

- **File & Class Naming**:
  - Location: `app/operations/v1/users/create_operation.rb`
  - Class: `class V1::Users::CreateOperation < ApplicationOperation`
- **Public Interface**: Only the `call` method is public. Internal steps are implemented as private methods named `step_*`.
- **Single Responsibility Steps**: Each `step_*` method performs one distinct task.
- **Limited Inheritance**: Primarily inherit from `ApplicationOperation` or a parent namespace operation.

### 3.3. Form

- **File & Class Naming**:
  - Location: `app/forms/v1/users/create_form.rb`
  - Class: `class V1::Users::CreateForm < ApplicationForm`
- **Purpose**: Solely for validation using `valid!` or `validate`.
- **No DB Interaction**.

### 3.4. Model

- **Content**: Contains only associations, scopes, and enums.
- **Extended Logic**: Place in `app/models/concerns/...` and include in the model.

### 3.5. Error Layer

- **`Errorable` Module** (typically in `ApplicationController`):
  - Rescues exceptions and delegates to `Renderable#render_error`.
  - Sends notifications for 500 errors.
  - Filters sensitive fields from parameters.

---

## 4. Example Implementation

```ruby
# app/controllers/v1/users_controller.rb
class V1::UsersController < ApplicationController
  def create
    op = V1::Users::CreateOperation.new(params, current_member: current_member)
    op.call
    render_json(op.result)
  end

  def destroy
    op = V1::Users::DestroyOperation.new(params, current_member: current_member)
    op.call
    render_json(op.result)
  end
end

# app/operations/v1/users/create_operation.rb
class V1::Users::CreateOperation < ApplicationOperation
  def call
    step_validate
    step_create_record
    step_notify_user
  end

  private

  def step_validate
    V1::Users::CreateForm.new(params).valid!
  end

  def step_create_record
    @user = User.create!(permitted_params)
  end

  def step_notify_user
    UserMailer.welcome(@user).deliver_later
  end
end

# app/forms/v1/users/create_form.rb
class V1::Users::CreateForm < ApplicationForm
  attribute :email, :string
  attribute :password, :string

  validates :email, :password, presence: true
end
```
