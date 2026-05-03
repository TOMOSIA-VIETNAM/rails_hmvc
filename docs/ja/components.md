# コンポーネント

生成後に各レイヤーをどう実装するかの指針です。コンポーネントごとに役割はひとつ — ドメインロジックが境界をまたがって漏れないようにします。

## Controller

HTTP だけ担当: リクエストを受け、Operation を実行し、レスポンスを返す。ビジネスロジックは持たず、DB に直接触れません。

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

**Render 用ヘルパー**（`Renderable` concern から提供）:

| メソッド | 使い分け |
|----------|----------|
| `render_collection(collection:, serializer:, meta:)` | ページングあり／なしの `index` 用ペイロード |
| `render_resource(resource:, serializer:, status:)` | 単一の resource |
| `render_error(error, status)` | エラーを手動でレンダリングするとき |
| `head :no_content` | 本体なしの `destroy` 成功 |

**慣習:**

- `MainController` または `ApiController` を継承する
- `wrap_parameters false` は `MainController` 側で設定済み
- ActiveRecord を直接呼ばない
- ここで例外を rescue しない — `Errorable` にエラーレスポンスの正規化を任せる

---

## Form

入力を検証し正規化する。不正ならドメインエラーで早期に失敗させる。永続化はしない。

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

**Operation 内での Form の使い方:**

```ruby
@form = V1::Users::CreateForm.new(params)
@form.valid!              # raises Errors::ResourceError when invalid
@form.attributes          # => { email: "...", password: "...", name: "...", role: "user" }
```

**慣習:**

- `MainForm` を継承する
- `attribute :name, :type` でフィールドを宣言する
- 標準の `ActiveModel::Validations` を使う
- `valid!` は検証失敗時に `Errors::ResourceError` を送出する
- DB や外向き HTTP は呼ばない

---

## Operation

ビジネスロジックをカプセル化する。公開 API は `call` のみ。非自明なフローは private の `step_*` に分割する。

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

**Controller から `current_user` を渡す:**

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

**慣習:**

- `MainOperation` を継承する
- 公開メソッドは `call` のみ
- 実装の細部は private の `step_*` に置く
- Controller が `operator.result` で読めるよう `@result` をセットする
- 例外を rescue しない — `Errorable` まで伝播させる

---

## Serializer

レコードを JSON に投影する。表現だけ — 分岐まみちのビジネスルールは持たない。

```ruby
# app/serializers/v1/user_serializer.rb
# frozen_string_literal: true

class V1::UserSerializer < MainSerializer
  attributes :id, :email, :name, :role, :created_at

  has_many :posts, serializer: V1::PostSerializer
  belongs_to :organization, serializer: V1::OrganizationSerializer
end
```

**慣習:**

- `MainSerializer` を継承する
- 表面積は `attributes` と association 宣言に限定する
- 複雑な条件分岐やドメインロジックは避ける

---

## エラーハンドリング

`MainController` の `Errorable` が例外と HTTP レスポンスの対応を取る。

**組み込みの rescue:**

| 例外 | HTTP ステータス |
|------|------------------|
| `StandardError` | 500 Internal Server Error |
| `ActiveRecord::RecordNotFound` | 404 Not Found |
| `ActiveRecord::RecordInvalid` | 422 Unprocessable Entity |
| `Errors::ResourceError` | 422 Unprocessable Entity |
| `Errors::APIError` | エラーオブジェクトが保持するステータス |

**Operation からの raise:**

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

**アプリケーション層のエラー**（`lib/errors/application_error.rb` から）:

```ruby
# 404
raise NotFoundError, "User #{id} not found"

# 401
raise UnauthorizedError

# 403
raise ForbiddenError, "Insufficient permissions"
```
