# Generators

All generators read defaults from `config/rails_hmvc.yml`. CLI flags override those defaults.

## `rails_hmvc:init`

Bootstraps the HMVC structure inside a Rails application.

```bash
rails g rails_hmvc:init --type=api
rails g rails_hmvc:init --type=web
```

**Output:** directories, base classes, concerns, error stubs, and `config/rails_hmvc.yml`.

---

## `rails_hmvc:controller`

Generates a controller together with matching operations and forms.

```bash
rails g rails_hmvc:controller v1/users --type=api
```

**Default output (API):**

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

| Option | Description | Example |
|--------|-------------|---------|
| `--type` | `api` or `web` | `--type=api` |
| `--actions` | Restrict generated actions | `--actions=index,show` |
| `--parent` | Base controller class | `--parent=ApiController` |
| `--skip_operation` | Skip operation files | |
| `--skip_form` | Skip form files | |
| `--parent_operation` | Base operation class | `--parent_operation=MainOperation` |
| `--parent_form` | Base form class | `--parent_form=MainForm` |

**Examples:**

```bash
# Custom, non-CRUD actions
rails g rails_hmvc:controller v1/auth --type=api --actions=login,register,logout

# Controller + forms only
rails g rails_hmvc:controller v1/categories --type=api --skip_operation

# Web stack (includes new/edit actions)
rails g rails_hmvc:controller admin/products --type=web
```

---

## `rails_hmvc:operation`

Generates one or more standalone operations.

```bash
rails g rails_hmvc:operation v1/payments/process
```

**Options:**

| Option | Description | Example |
|--------|-------------|---------|
| `--type` | `api` or `web` | `--type=api` |
| `--actions` | Multiple operations in one run | `--actions=approve,reject,ship` |
| `--steps` | Predeclare `step_*` hooks | `--steps=validate,process,notify` |
| `--parent` | Base operation class | `--parent=MainOperation` |

**Examples:**

```bash
# Single operation
rails g rails_hmvc:operation v1/payments/process

# Batch of related operations
rails g rails_hmvc:operation v1/orders --actions=approve,reject,ship

# Operation skeleton with step methods
rails g rails_hmvc:operation v1/checkout/complete --steps=validate,process_payment,create_order
```

---

## `rails_hmvc:form`

Generates one or more standalone forms.

```bash
rails g rails_hmvc:form v1/auth/login --attributes=email:string,password:string
```

**Options:**

| Option | Description | Example |
|--------|-------------|---------|
| `--type` | `api` or `web` | `--type=api` |
| `--actions` | Multiple forms in one run | `--actions=create,update` |
| `--attributes` | Declare typed attributes | `--attributes=name:string,price:decimal` |
| `--parent` | Base form class | `--parent=MainForm` |

**Examples:**

```bash
# Form with explicit attributes
rails g rails_hmvc:form v1/auth/login --attributes=email:string,password:string

# Pair of forms sharing the same attribute set
rails g rails_hmvc:form v1/products --actions=create,update --attributes=name:string,price:decimal,active:boolean
```

---

## Configuration (`config/rails_hmvc.yml`)

Created by `init`. Every key is a default consumed by the generators.

```yaml
type: api  # api or web

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

Adjust `parent` when your app uses different base classes (for example `ApiController` instead of `MainController`).
