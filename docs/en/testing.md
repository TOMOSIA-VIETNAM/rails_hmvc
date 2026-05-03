# Manual testing guide

Exercise the generators end-to-end against a disposable example application.

## Setup

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

### API project

```bash
rails g rails_hmvc:init --type=api
```

Verify the layout:

| Directory | Present |
|-----------|---------|
| `app/controllers` | ✓ |
| `app/operations` | ✓ |
| `app/forms` | ✓ |
| `app/serializers` | ✓ |
| `app/models` | ✓ |
| `lib/errors` | ✓ |
| `app/controllers/concerns` | ✓ |
| `config/initializers` | ✓ |

| File | Present |
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
rails g rails_hmvc:init --type=web
```

Structure matches the API run; template contents differ (web-oriented stubs).

---

## 2. `controller` generator

### Default actions (API)

```bash
rails g rails_hmvc:controller v1/users --type=api
```

Expected files:

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
rails g rails_hmvc:controller admin/products --type=web
```

Expect one controller, seven operations (`new` and `edit` included), and two forms.

### Limited actions

```bash
rails g rails_hmvc:controller v1/posts --type=api --actions=index,show
```

Expect one controller, two operations, and no forms.

### Custom actions

```bash
rails g rails_hmvc:controller v1/auth --type=api --actions=login,logout,register
```

Expect one controller, three operations, and forms according to `rails_hmvc.yml`.

### Skip operations

```bash
rails g rails_hmvc:controller v1/categories --type=api --skip_operation
```

Expect one controller, no operations, and two forms.

### Skip forms

```bash
rails g rails_hmvc:controller v1/tags --type=api --skip_form
```

Expect one controller, five operations, and no forms.

### Skip both

```bash
rails g rails_hmvc:controller v1/comments --type=api --skip_operation --skip_form
```

Expect only the controller.

---

## 3. `operation` generator

### Single operation

```bash
rails g rails_hmvc:operation v1/payments/process
```

Expected: `app/operations/v1/payments/process_operation.rb`

### Multiple operations

```bash
rails g rails_hmvc:operation v1/orders --actions=approve,reject,ship
```

Expected:

```
app/operations/v1/orders/approve_operation.rb
app/operations/v1/orders/reject_operation.rb
app/operations/v1/orders/ship_operation.rb
```

### With step methods

```bash
rails g rails_hmvc:operation v1/checkout/complete --steps=validate,process_payment,create_order
```

Expected: `app/operations/v1/checkout/complete_operation.rb` containing three `step_*` methods.

---

## 4. `form` generator

### Single form with attributes

```bash
rails g rails_hmvc:form v1/auth/login --attributes=email:string,password:string
```

Expected: `app/forms/v1/auth/login_form.rb` declaring `attribute :email, :string` and `attribute :password, :string`.

### Multiple forms

```bash
rails g rails_hmvc:form v1/products --actions=create,update --attributes=name:string,price:decimal,active:boolean
```

Expected:

```
app/forms/v1/products/create_form.rb
app/forms/v1/products/update_form.rb
```

Both include the same three attributes.

### Form without explicit attributes

```bash
rails g rails_hmvc:form v1/auth/logout
```

Expected: `app/forms/v1/auth/logout_form.rb` with the generator default `attribute :name, :string`.

---

## 5. Combination test

Walk through a full resource plus extras:

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

Assert every file exists, namespaces line up, inheritance matches your bases, and naming stays consistent.
