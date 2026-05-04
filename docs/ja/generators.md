# Generators

すべての generator は `config/rails_hmvc.yml` のデフォルトを読みます。CLI のフラグはそのデフォルトを上書きします。

`rails g hmvc:<name>` で生成し、`rails d hmvc:<name>` に同じ引数を渡すことでファイルを削除できます。`hmvc g <name>` は `rails g hmvc:<name>` の短縮エイリアスです。

## `hmvc:init`

Rails アプリケーション内に HMVC 構成を用意します。

```bash
rails g hmvc:init --type=api
rails g hmvc:init --type=web
```

**出力:** ディレクトリ、ベースクラス、concern、エラー用スタブ、`config/rails_hmvc.yml`。

---

## `hmvc:controller`

Controller と、対になる Operation / Form をまとめて生成します。

```bash
rails g hmvc:controller v1/users --type=api
```

**デフォルト出力（API）:**

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

**オプション:**

| オプション | 説明 | 例 |
|------------|------|-----|
| `--type` | `api` または `web` | `--type=api` |
| `--actions` | 生成する action を絞る | `--actions=index,show` |
| `--parent` | 基底 Controller クラス | `--parent=ApiController` |
| `--skip_operation` | Operation ファイルをスキップ | |
| `--skip_form` | Form ファイルをスキップ | |
| `--parent_operation` | 基底 Operation クラス | `--parent_operation=MainOperation` |
| `--parent_form` | 基底 Form クラス | `--parent_form=MainForm` |

**例:**

```bash
# Custom, non-CRUD actions
rails g hmvc:controller v1/auth --type=api --actions=login,register,logout

# Controller + forms only
rails g hmvc:controller v1/categories --type=api --skip_operation

# Web stack (includes new/edit actions)
rails g hmvc:controller admin/products --type=web
```

**Destroy:**

```bash
rails d hmvc:controller v1/users --type=api
```

対応する `rails g` コマンドで作成されたすべてのファイルを削除します。

---

## `hmvc:operation`

単体の Operation を 1 つ以上生成します。

```bash
rails g hmvc:operation v1/payments/process
```

**オプション:**

| オプション | 説明 | 例 |
|------------|------|-----|
| `--type` | `api` または `web` | `--type=api` |
| `--actions` | 一度に複数 Operation を作る | `--actions=approve,reject,ship` |
| `--steps` | `step_*` をあらかじめ宣言 | `--steps=validate,process,notify` |
| `--parent` | 基底 Operation クラス | `--parent=MainOperation` |

**例:**

```bash
# Single operation
rails g hmvc:operation v1/payments/process

# Batch of related operations
rails g hmvc:operation v1/orders --actions=approve,reject,ship

# Operation skeleton with step methods
rails g hmvc:operation v1/checkout/complete --steps=validate,process_payment,create_order
```

---

## `hmvc:form`

単体の Form を 1 つ以上生成します。

```bash
rails g hmvc:form v1/auth/login --attributes=email:string,password:string
```

**オプション:**

| オプション | 説明 | 例 |
|------------|------|-----|
| `--type` | `api` または `web` | `--type=api` |
| `--actions` | 一度に複数 Form を作る | `--actions=create,update` |
| `--attributes` | 型付き attribute を宣言 | `--attributes=name:string,price:decimal` |
| `--parent` | 基底 Form クラス | `--parent=MainForm` |

**例:**

```bash
# Form with explicit attributes
rails g hmvc:form v1/auth/login --attributes=email:string,password:string

# Pair of forms sharing the same attribute set
rails g hmvc:form v1/products --actions=create,update --attributes=name:string,price:decimal,active:boolean
```

---

## 設定（`config/rails_hmvc.yml`）

`init` で作成されます。各キーは generator が参照するデフォルトです。

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

ベースクラスが異なるアプリでは `parent` を調整してください（例: `MainController` の代わりに `ApiController`）。
