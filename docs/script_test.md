# Manual Test Scripts

## Setup Test Environment

```bash
# 1. Xóa thư mục example cũ và tạo mới Rails app
rm -rf example && rails new example --api --skip-git --skip-javascript

# 2. Thêm rails_hmvc gem và cài đặt dependencies
cd example && bundle add rails_hmvc --path ".." && bundle install --path vendor/bundle

# 3. Kiểm tra gem đã được cài đặt và có các generators
bundle info rails_hmvc

# 4. Khởi tạo HMVC structure
rails g rails_hmvc:init --force --no-stdin
```

## Test Cases

### 1. Test API Resource Generation (Default Type)

```bash
# Generate API resource với namespace v1
rails g rails_hmvc:resources v1/posts --type=api

# Kiểm tra các file được tạo
ls -la app/controllers/v1/posts_controller.rb
ls -la app/operations/v1/posts/
ls -la app/forms/v1/posts/
ls -la app/serializers/v1/post_serializer.rb

# Kiểm tra routes được thêm vào
cat config/routes.rb
```

### 2. Test Web Resource Generation

```bash
# Generate Web resource với namespace admin
rails g rails_hmvc:resources admin/products --type=web

# Kiểm tra các file được tạo
ls -la app/controllers/admin/products_controller.rb
ls -la app/operations/admin/products/
ls -la app/forms/admin/products/
ls -la app/serializers/admin/product_serializer.rb
```

### 3. Test Resource với Custom Actions

```bash
# Generate resource với custom actions
rails g rails_hmvc:resources v1/orders --actions=index,show,create --type=api

# Kiểm tra controller và routes
cat app/controllers/v1/orders_controller.rb
cat config/routes.rb
```

### 4. Test Form Generator với Validations

```bash
# Generate form với attributes và validations
rails g rails_hmvc:form v1/users/create \
  --attributes=name:string email:string age:integer \
  --validations=name:presence:true email:presence:true \
  --type=api

# Kiểm tra form được tạo
cat app/forms/v1/users/create_form.rb
```

### 5. Test Operation Generator với Custom Parent

```bash
# Generate operation với custom parent class
rails g rails_hmvc:operation v1/products/create --parent=SearchOperation --type=api

# Kiểm tra operation được tạo
cat app/operations/v1/products/create_operation.rb
```

### 6. Test Controller Generator với Skip Options

```bash
# Generate controller với skip options
rails g rails_hmvc:controller v1/categories \
  --skip-operations \
  --skip-forms \
  --actions=index,show \
  --type=api

# Kiểm tra controller được tạo
cat app/controllers/v1/categories_controller.rb
```

### 7. Test Resource với Multiple Namespaces

```bash
# Generate resource với nhiều namespace
rails g rails_hmvc:resources api/v2/customers --type=api

# Kiểm tra cấu trúc thư mục và namespace
ls -la app/controllers/api/v2/
cat app/controllers/api/v2/customers_controller.rb
```

### 8. Test Configuration Override

```bash
# Sửa config/rails_hmvc.yml để thay đổi parent classes
cat > config/rails_hmvc.yml << EOL
type: api
api:
  parent_controller: CustomController
  parent_operation: CustomOperation
  parent_form: CustomForm
  parent_serializer: CustomSerializer
EOL

# Generate resource để kiểm tra override
rails g rails_hmvc:resources v1/comments --type=api

# Kiểm tra parent classes
cat app/controllers/v1/comments_controller.rb
cat app/operations/v1/comments/index_operation.rb
cat app/forms/v1/comments/create_form.rb
```

### 9. Test Resource Configuration trong YAML

```bash
# Thêm cấu hình resource vào rails_hmvc.yml
cat >> config/rails_hmvc.yml << EOL
  controllers:
    actions: [index, show]
  operations:
    actions: [index, show]
  forms:
    actions: [create]
    skip_actions: []
EOL

# Generate resource để kiểm tra cấu hình
rails g rails_hmvc:resources v1/tags --type=api

# Kiểm tra các actions được tạo
cat app/controllers/v1/tags_controller.rb
ls -la app/operations/v1/tags/
ls -la app/forms/v1/tags/
```

### 10. Cleanup Test Environment

```bash
# Quay về thư mục gốc và xóa test app
cd ..
rm -rf example
```

## Expected Results

Sau khi chạy các test cases trên, cần kiểm tra:

1. Tất cả các file được tạo đúng vị trí và namespace
2. Comments về HTTP method và route trong controllers
3. Parent classes được áp dụng đúng theo cấu hình
4. Routes được tạo đúng với namespaces
5. Forms có đầy đủ attributes và validations
6. Operations được tạo với đúng cấu trúc
7. Serializers được tạo đúng format

## Known Issues

Nếu gặp lỗi trong quá trình test, vui lòng kiểm tra:

1. Phiên bản Ruby và Rails tương thích
2. Gem đã được cài đặt đúng cách
3. Path tới gem trong Gemfile
4. Quyền truy cập thư mục

## Results test

1. Web sẽ không tạo serializer
2. Router:
  - Các indent đang bị tụt ra ngoài
  - Route chưa gom vào scope
3. Chưa skip operations
```
rails g rails_hmvc:controller v1/categories \
  --skip-operations \
  --skip-forms \
  --actions=index,show \
  --type=api
```
