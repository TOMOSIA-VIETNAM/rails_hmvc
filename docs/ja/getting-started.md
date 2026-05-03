# はじめに

> Rails アプリに HMVC の骨組みを、おおよそ 5 分で用意できます。

## 要件

- Ruby >= 2.7.0
- Rails >= 6.1.0

## 1. gem のインストール

`Gemfile` に追加します。

```ruby
gem 'rails_hmvc'
```

続けて実行します。

```bash
bundle install
```

## 2. HMVC 構成の初期化

```bash
rails g rails_hmvc:init --type=api
```

ディレクトリツリー、ベースクラス、concern、設定が scaffold されます。

```
app/
├── controllers/
│   ├── main_controller.rb        # Base controller
│   ├── api_controller.rb         # API base controller
│   └── concerns/
│       ├── renderable.rb         # render_collection, render_resource helpers
│       └── errorable.rb          # rescue_from error handlers
├── forms/
│   └── main_form.rb              # Base form (ActiveModel::Model + Attributes)
├── operations/
│   └── main_operation.rb         # Base operation
└── serializers/
    ├── main_serializer.rb
    └── error_serializer.rb

lib/errors/
├── application_error.rb          # Base error classes
└── resource_error.rb

config/
└── rails_hmvc.yml                # Generator defaults
```

> 従来の web アプリ向け: `rails g rails_hmvc:init --type=web`

## 3. 最初の resource を生成する

```bash
rails g rails_hmvc:controller v1/users --type=api
```

生成される成果物:

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

## 4. ルーティングをつなぐ

```ruby
# config/routes.rb
namespace :v1 do
  resources :users
end
```

## 5. ドメインロジックを実装する

生成された各ファイルを開き、振る舞いを書き込みます。

- **Controller**（`app/controllers/v1/users_controller.rb`）— Operation に委譲し、レスポンスのレンダリングだけにとどめる
- **Form**（`app/forms/v1/users/create_form.rb`）— attribute と validation を宣言する
- **Operation**（`app/operations/v1/users/create_operation.rb`）— `step_*` メソッドにビジネスルールを書く

レイヤーごとの慣習は [components.md](components.md) を参照してください。

## 次のステップ

- [architecture.md](architecture.md) — HMVC の全体像
- [generators.md](generators.md) — generator のオプションとフラグ
- [components.md](components.md) — Controller / Operation / Form / Serializer のパターン
