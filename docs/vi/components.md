# Components

Hướng dẫn viết code cho từng component sau khi generate. Mỗi component có một trách nhiệm rõ ràng — đừng để logic "rò rỉ" sang layer khác.

## Controller

Chỉ xử lý HTTP: nhận request, gọi Operation, trả response. Không có business logic, không gọi DB.

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

**Render helpers** (từ `Renderable` concern):

| Method | Dùng khi |
|--------|----------|
| `render_collection(collection:, serializer:, meta:)` | Trả về danh sách (index) |
| `render_resource(resource:, serializer:, status:)` | Trả về 1 object |
| `render_error(error, status)` | Render error thủ công |
| `head :no_content` | Destroy, không trả body |

**Quy tắc:**
- Inherit từ `MainController` hoặc `ApiController`
- `wrap_parameters false` (đã có trong `MainController`)
- Không gọi DB trực tiếp
- Không rescue exception thủ công (để `Errorable` xử lý)

---

## Form

Validate và transform input. Raise lỗi nếu invalid. Không chạm DB.

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

**Dùng trong Operation:**

```ruby
@form = V1::Users::CreateForm.new(params)
@form.valid!              # raise Errors::ResourceError nếu invalid
@form.attributes          # => { email: "...", password: "...", name: "...", role: "user" }
```

**Quy tắc:**
- Inherit từ `MainForm`
- Khai báo attributes với `attribute :name, :type`
- Dùng `ActiveModel::Validations` standard
- `valid!` raise `Errors::ResourceError` nếu invalid
- Không gọi DB, không gọi external services

---

## Operation

Chứa toàn bộ business logic. Interface duy nhất là `call`. Logic phức tạp tách thành `step_` methods.

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

**Nhận `current_user`:**

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

Controller truyền `current_user` qua params:

```ruby
operator = Users::UpdateOperation.call(params: params.merge(current_user: current_user))
```

**Quy tắc:**
- Inherit từ `MainOperation`
- Chỉ có 1 public method: `call`
- Mọi logic tách vào `step_` private methods
- Đặt `@result` để controller lấy kết quả qua `operator.result`
- Không rescue exception (để bubble lên `Errorable`)

---

## Serializer

Format data thành JSON. Không chứa logic.

```ruby
# app/serializers/v1/user_serializer.rb
# frozen_string_literal: true

class V1::UserSerializer < MainSerializer
  attributes :id, :email, :name, :role, :created_at

  has_many :posts, serializer: V1::PostSerializer
  belongs_to :organization, serializer: V1::OrganizationSerializer
end
```

**Quy tắc:**
- Inherit từ `MainSerializer`
- Chỉ khai báo `attributes` và associations
- Không chứa điều kiện phức tạp hay business logic

---

## Error Handling

Errors được xử lý tự động bởi `Errorable` concern trong `MainController`.

**Các error được rescue sẵn:**

| Exception | HTTP Status |
|-----------|------------|
| `StandardError` | 500 Internal Server Error |
| `ActiveRecord::RecordNotFound` | 404 Not Found |
| `ActiveRecord::RecordInvalid` | 422 Unprocessable Entity |
| `Errors::ResourceError` | 422 Unprocessable Entity |
| `Errors::APIError` | status từ error object |

**Raise lỗi trong Operation:**

```ruby
# Lỗi không tìm thấy record
raise ActiveRecord::RecordNotFound, "User not found"

# Lỗi từ form validation (tự động qua valid!)
@form.valid!

# Lỗi custom với status tùy chỉnh
raise Errors::APIError.new("Payment failed", status: 402, code: 'payment_failed')

# Lỗi resource (kèm danh sách errors)
raise Errors::ResourceError.new(resource: user, message: user.errors.full_messages)
```

**Custom error classes** (từ `lib/errors/application_error.rb`):

```ruby
# 404
raise NotFoundError, "User #{id} not found"

# 401
raise UnauthorizedError

# 403
raise ForbiddenError, "Insufficient permissions"
```
