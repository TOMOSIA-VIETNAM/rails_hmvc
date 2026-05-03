# Getting Started

> Thiết lập HMVC structure trong Rails app của bạn trong 5 phút.

## Yêu cầu

- Ruby >= 2.7.0
- Rails >= 6.1.0

## 1. Cài đặt gem

Thêm vào `Gemfile`:

```ruby
gem 'rails_hmvc'
```

Chạy:

```bash
bundle install
```

## 2. Khởi tạo HMVC structure

```bash
rails g rails_hmvc:init --type=api
```

Lệnh này tạo ra toàn bộ cấu trúc thư mục, base classes, concerns, và config file:

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

> Với web app: `rails g rails_hmvc:init --type=web`

## 3. Tạo resource đầu tiên

```bash
rails g rails_hmvc:controller v1/users --type=api
```

Kết quả:

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

## 4. Thêm routes

```ruby
# config/routes.rb
namespace :v1 do
  resources :users
end
```

## 5. Implement logic

Mở từng file được generate ra và điền logic:

- **Controller** `app/controllers/v1/users_controller.rb` — chỉ gọi Operation, render response
- **Form** `app/forms/v1/users/create_form.rb` — thêm attributes và validations
- **Operation** `app/operations/v1/users/create_operation.rb` — viết business logic trong các `step_` methods

Xem [components.md](components.md) để biết cách viết từng loại component đúng chuẩn.

## Các bước tiếp theo

- [architecture.md](architecture.md) — Hiểu cách HMVC hoạt động
- [generators.md](generators.md) — Tất cả options của generators
- [components.md](components.md) — Cách viết Controllers, Operations, Forms, Serializers
