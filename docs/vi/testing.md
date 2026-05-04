# Manual Testing Guide

Hướng dẫn test thủ công các generators trên example app.

## Setup

```bash
# Tạo mới example app
rm -rf example && rails new example --api --skip-git --skip-javascript

# Add gem từ local source
cd example
bundle add rails_hmvc --path ".."
bundle install --path vendor/bundle
bundle info rails_hmvc
```

---

## 1. `init` Generator

### API project

```bash
rails g hmvc:init --type=api
```

Kiểm tra output:

| Thư mục | Tồn tại |
|---------|---------|
| `app/controllers` | ✓ |
| `app/operations` | ✓ |
| `app/forms` | ✓ |
| `app/serializers` | ✓ |
| `app/models` | ✓ |
| `lib/errors` | ✓ |
| `app/controllers/concerns` | ✓ |
| `config/initializers` | ✓ |

| File | Tồn tại |
|------|---------|
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

### Web project

```bash
rails g hmvc:init --type=web
```

Output giống API, nội dung file khác (web-specific templates).

---

## 2. `controller` Generator

### Default actions (API)

```bash
rails g hmvc:controller v1/users --type=api
```

Expected:

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

### Default actions (Web)

```bash
rails g hmvc:controller admin/products --type=web
```

Expected: 1 controller + 7 operations (thêm `new`, `edit`) + 2 forms.

### Limited actions

```bash
rails g hmvc:controller v1/posts --type=api --actions=index,show
```

Expected: 1 controller + 2 operations + 0 forms.

### Custom actions

```bash
rails g hmvc:controller v1/auth --type=api --actions=login,logout,register
```

Expected: 1 controller + 3 operations + forms tùy theo config.

### Skip operations

```bash
rails g hmvc:controller v1/categories --type=api --skip_operation
```

Expected: 1 controller + 0 operations + 2 forms.

### Skip forms

```bash
rails g hmvc:controller v1/tags --type=api --skip_form
```

Expected: 1 controller + 5 operations + 0 forms.

### Skip both

```bash
rails g hmvc:controller v1/comments --type=api --skip_operation --skip_form
```

Expected: 1 controller, không có operations và forms.

---

## 3. `operation` Generator

### Single operation

```bash
rails g hmvc:operation v1/payments/process
```

Expected: `app/operations/v1/payments/process_operation.rb`

### Multiple operations

```bash
rails g hmvc:operation v1/orders --actions=approve,reject,ship
```

Expected:

```
app/operations/v1/orders/approve_operation.rb
app/operations/v1/orders/reject_operation.rb
app/operations/v1/orders/ship_operation.rb
```

### With step methods

```bash
rails g hmvc:operation v1/checkout/complete --steps=validate,process_payment,create_order
```

Expected: `app/operations/v1/checkout/complete_operation.rb` với 3 `step_` methods.

---

## 4. `form` Generator

### Single form với attributes

```bash
rails g hmvc:form v1/auth/login --attributes=email:string,password:string
```

Expected: `app/forms/v1/auth/login_form.rb` với `attribute :email, :string` và `attribute :password, :string`.

### Multiple forms

```bash
rails g hmvc:form v1/products --actions=create,update --attributes=name:string,price:decimal,active:boolean
```

Expected:

```
app/forms/v1/products/create_form.rb
app/forms/v1/products/update_form.rb
```

Cả hai đều có 3 attributes.

### Form không có attributes

```bash
rails g hmvc:form v1/auth/logout
```

Expected: `app/forms/v1/auth/logout_form.rb` với default `attribute :name, :string`.

---

## 5. Combination Test

Test đầy đủ một resource hoàn chỉnh:

```bash
# 1. Init
rails g hmvc:init --type=api

# 2. Generate resource chính
rails g hmvc:controller v1/articles --type=api

# 3. Operation thêm (ngoài CRUD)
rails g hmvc:operation v1/articles/publish --steps=validate,notify

# 4. Form search tùy chỉnh
rails g hmvc:form v1/articles/search --attributes=keyword:string,category_id:integer,published:boolean
```

Kiểm tra: tất cả files tồn tại, đúng namespace, đúng inheritance, consistent naming.
