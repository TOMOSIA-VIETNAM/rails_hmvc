# 手動テストガイド

捨てられる example アプリ上で、generator を端到端で試します。

## セットアップ

```bash
# Fresh example app
rm -rf example && rails new example --api --skip-git --skip-javascript

# Point Bundler at the local gem
cd example
bundle add rails_hmvc --path ".."
bundle install --path vendor/bundle
bundle info rails_hmvc
```

---

## 1. `init` generator

### API プロジェクト

```bash
rails g rails_hmvc:init --type=api
```

レイアウトを確認する:

| ディレクトリ | 存在 |
|--------------|------|
| `app/controllers` | ✓ |
| `app/operations` | ✓ |
| `app/forms` | ✓ |
| `app/serializers` | ✓ |
| `app/models` | ✓ |
| `lib/errors` | ✓ |
| `app/controllers/concerns` | ✓ |
| `config/initializers` | ✓ |

| ファイル | 存在 |
|----------|------|
| `config/rails_hmvc.yml` | ✓ |
| `lib/errors/application_error.rb` | ✓ |
| `lib/errors/resource_error.rb` | ✓ |
| `app/controllers/main_controller.rb` | ✓ |
| `app/controllers/api_controller.rb` | ✓ |
| `app/forms/main_form.rb` | ✓ |
| `app/operations/main_operation.rb` | ✓ |
| `app/serializers/main_serializer.rb` | ✓ |
| `app/serializers/error_serializer.rb` | ✓ |
| `app/controllers/concerns/renderable.rb` | ✓ |
| `app/controllers/concerns/errorable.rb` | ✓ |

### Web プロジェクト

```bash
rails g rails_hmvc:init --type=web
```

構成は API 実行時と同じ。テンプレートの中身のみ web 向けスタブが異なります。

---

## 2. `controller` generator

### デフォルトの actions（API）

```bash
rails g rails_hmvc:controller v1/users --type=api
```

期待されるファイル:

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

### デフォルトの actions（Web）

```bash
rails g rails_hmvc:controller admin/products --type=web
```

Controller が 1 つ、Operation が 7 つ（`new` と `edit` を含む）、Form が 2 つになる想定です。

### actions を限定する

```bash
rails g rails_hmvc:controller v1/posts --type=api --actions=index,show
```

Controller 1 つ、Operation 2 つ、Form なしを期待します。

### カスタム actions

```bash
rails g rails_hmvc:controller v1/auth --type=api --actions=login,logout,register
```

Controller 1 つ、Operation 3 つ、Form は `rails_hmvc.yml` に従う想定です。

### Operation をスキップ

```bash
rails g rails_hmvc:controller v1/categories --type=api --skip_operation
```

Controller 1 つ、Operation なし、Form 2 つを期待します。

### Form をスキップ

```bash
rails g rails_hmvc:controller v1/tags --type=api --skip_form
```

Controller 1 つ、Operation 5 つ、Form なしを期待します。

### 両方スキップ

```bash
rails g rails_hmvc:controller v1/comments --type=api --skip_operation --skip_form
```

Controller のみを期待します。

---

## 3. `operation` generator

### 単一の Operation

```bash
rails g rails_hmvc:operation v1/payments/process
```

期待: `app/operations/v1/payments/process_operation.rb`

### 複数の Operation

```bash
rails g rails_hmvc:operation v1/orders --actions=approve,reject,ship
```

期待:

```
app/operations/v1/orders/approve_operation.rb
app/operations/v1/orders/reject_operation.rb
app/operations/v1/orders/ship_operation.rb
```

### step メソッド付き

```bash
rails g rails_hmvc:operation v1/checkout/complete --steps=validate,process_payment,create_order
```

期待: `app/operations/v1/checkout/complete_operation.rb` に 3 つの `step_*` メソッド。

---

## 4. `form` generator

### attribute 付きの単一 Form

```bash
rails g rails_hmvc:form v1/auth/login --attributes=email:string,password:string
```

期待: `app/forms/v1/auth/login_form.rb` に `attribute :email, :string` と `attribute :password, :string`。

### 複数の Form

```bash
rails g rails_hmvc:form v1/products --actions=create,update --attributes=name:string,price:decimal,active:boolean
```

期待:

```
app/forms/v1/products/create_form.rb
app/forms/v1/products/update_form.rb
```

どちらも同じ 3 つの attribute を持つ想定です。

### attribute を明示しない Form

```bash
rails g rails_hmvc:form v1/auth/logout
```

期待: `app/forms/v1/auth/logout_form.rb` に generator 既定の `attribute :name, :string`。

---

## 5. 組み合わせテスト

resource 一式に加えて追加コンポーネントまで通す:

```bash
# 1. Init
rails g rails_hmvc:init --type=api

# 2. Primary CRUD resource
rails g rails_hmvc:controller v1/articles --type=api

# 3. Additional operation beyond CRUD
rails g rails_hmvc:operation v1/articles/publish --steps=validate,notify

# 4. Custom search form
rails g rails_hmvc:form v1/articles/search --attributes=keyword:string,category_id:integer,published:boolean
```

すべてのファイルが存在し、namespace・継承・命名がベースクラスと整合していることを確認します。
