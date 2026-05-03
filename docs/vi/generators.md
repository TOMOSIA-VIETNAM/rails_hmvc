# Generators

Tất cả generators đọc defaults từ `config/rails_hmvc.yml`. CLI flags override config.

## `rails_hmvc:init`

Khởi tạo HMVC structure cho Rails app.

```bash
rails g rails_hmvc:init --type=api
rails g rails_hmvc:init --type=web
```

**Output:** Tạo thư mục, base classes, concerns, error classes, `config/rails_hmvc.yml`.

---

## `rails_hmvc:controller`

Tạo controller kèm operations và forms tương ứng.

```bash
rails g rails_hmvc:controller v1/users --type=api
```

**Output mặc định (API):**

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

**Options:**

| Option | Mô tả | Ví dụ |
|--------|-------|-------|
| `--type` | `api` hoặc `web` | `--type=api` |
| `--actions` | Giới hạn actions | `--actions=index,show` |
| `--parent` | Parent controller class | `--parent=ApiController` |
| `--skip_operation` | Không tạo operations | |
| `--skip_form` | Không tạo forms | |
| `--parent_operation` | Parent operation class | `--parent_operation=MainOperation` |
| `--parent_form` | Parent form class | `--parent_form=MainForm` |

**Ví dụ:**

```bash
# Actions tùy chỉnh (không phải CRUD)
rails g rails_hmvc:controller v1/auth --type=api --actions=login,register,logout

# Chỉ tạo controller + forms, không tạo operations
rails g rails_hmvc:controller v1/categories --type=api --skip_operation

# Web controller (tạo thêm new, edit actions)
rails g rails_hmvc:controller admin/products --type=web
```

---

## `rails_hmvc:operation`

Tạo operation(s) riêng lẻ.

```bash
rails g rails_hmvc:operation v1/payments/process
```

**Options:**

| Option | Mô tả | Ví dụ |
|--------|-------|-------|
| `--type` | `api` hoặc `web` | `--type=api` |
| `--actions` | Tạo nhiều operations | `--actions=approve,reject,ship` |
| `--steps` | Tạo `step_` methods sẵn | `--steps=validate,process,notify` |
| `--parent` | Parent operation class | `--parent=MainOperation` |

**Ví dụ:**

```bash
# Một operation đơn
rails g rails_hmvc:operation v1/payments/process

# Nhiều operations cùng lúc
rails g rails_hmvc:operation v1/orders --actions=approve,reject,ship

# Operation với step methods được tạo sẵn
rails g rails_hmvc:operation v1/checkout/complete --steps=validate,process_payment,create_order
```

---

## `rails_hmvc:form`

Tạo form(s) riêng lẻ.

```bash
rails g rails_hmvc:form v1/auth/login --attributes=email:string,password:string
```

**Options:**

| Option | Mô tả | Ví dụ |
|--------|-------|-------|
| `--type` | `api` hoặc `web` | `--type=api` |
| `--actions` | Tạo nhiều forms | `--actions=create,update` |
| `--attributes` | Định nghĩa attributes | `--attributes=name:string,price:decimal` |
| `--parent` | Parent form class | `--parent=MainForm` |

**Ví dụ:**

```bash
# Form với attributes
rails g rails_hmvc:form v1/auth/login --attributes=email:string,password:string

# Nhiều forms cùng attributes
rails g rails_hmvc:form v1/products --actions=create,update --attributes=name:string,price:decimal,active:boolean
```

---

## Configuration (`config/rails_hmvc.yml`)

File này được tạo bởi `init` generator. Mọi giá trị đều là defaults cho generators.

```yaml
type: api  # api hoặc web

api:
  controllers:
    parent: MainController
    actions: ['index', 'show', 'create', 'update', 'destroy']
  operations:
    parent: MainOperation
    actions: ['index', 'show', 'create', 'update', 'destroy']
  forms:
    parent: MainForm
    actions: ['create', 'update']

web:
  controllers:
    parent: MainController
    actions: ['index', 'show', 'new', 'edit', 'create', 'update', 'destroy']
  operations:
    parent: MainOperation
    actions: ['index', 'show', 'new', 'edit', 'create', 'update', 'destroy']
  forms:
    parent: MainForm
    actions: ['create', 'update', 'new', 'edit']
```

Thay đổi `parent` nếu dự án của bạn dùng class khác làm base (ví dụ `ApiController` thay vì `MainController`).
