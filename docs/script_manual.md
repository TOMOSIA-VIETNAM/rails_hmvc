# Rails HMVC Generators - Test Script

Test script for manually validating the Rails HMVC generators. Each test case includes input command and expected output files.

## Setup project example

  ```
  rm -rf example && rails new example --api --skip-git --skip-javascript
  cd example && bundle add rails_hmvc --path ".." && bundle install --path vendor/bundle && bundle info rails_hmvc
  ```

## 1. `init` Generator

### Test Case 1.1: API Project Initialization
* **Input:**
  ```
  rails g rails_hmvc:init --type=api
  ```
* **Output:**
  * Directories: 8
    * `app/controllers`
    * `app/operations`
    * `app/forms`
    * `app/serializers`
    * `app/models`
    * `lib/errors`
    * `app/controllers/concerns`
    * `config/initializers`
  * Files: 8
    * `config/rails_hmvc.yml`: 1
    * `lib/errors/application_error.rb`: 1
    * `lib/errors/resource_error.rb`: 1
    * `app/controllers/main_controller.rb`: 1
    * `app/controllers/api_controller.rb`: 1
    * `app/forms/main_form.rb`: 1
    * `app/operations/main_operation.rb`: 1
    * `app/serializers/main_serializer.rb`: 1
    * `app/serializers/error_serializer.rb`: 1
    * `app/controllers/concerns/renderable.rb`: 1
    * `app/controllers/concerns/errorable.rb`: 1

### Test Case 1.2: Web Project Initialization
* **Input:**
  ```
  rails g rails_hmvc:init --type=web
  ```
* **Output:**
  * Same directories and files as Test Case 1.1
  * Different content based on web-specific templates

## 2. `controller` Generator

### Test Case 2.1: API Controller (Default Actions)
* **Input:**
  ```
  rails g rails_hmvc:controller v1/users --type=api
  ```
* **Output:**
  * Controllers: 1
    * `app/controllers/v1/users_controller.rb`
  * Operations: 5
    * `app/operations/v1/users/index_operation.rb`
    * `app/operations/v1/users/show_operation.rb`
    * `app/operations/v1/users/create_operation.rb`
    * `app/operations/v1/users/update_operation.rb`
    * `app/operations/v1/users/destroy_operation.rb`
  * Forms: 2
    * `app/forms/v1/users/create_form.rb`
    * `app/forms/v1/users/update_form.rb`

### Test Case 2.2: Web Controller (Default Actions)
* **Input:**
  ```
  rails g rails_hmvc:controller admin/products --type=web
  ```
* **Output:**
  * Controllers: 1
    * `app/controllers/admin/products_controller.rb`
  * Operations: 7
    * `app/operations/admin/products/index_operation.rb`
    * `app/operations/admin/products/show_operation.rb`
    * `app/operations/admin/products/new_operation.rb`
    * `app/operations/admin/products/create_operation.rb`
    * `app/operations/admin/products/edit_operation.rb`
    * `app/operations/admin/products/update_operation.rb`
    * `app/operations/admin/products/destroy_operation.rb`
  * Forms: 2
    * `app/forms/admin/products/create_form.rb`
    * `app/forms/admin/products/update_form.rb`

### Test Case 2.3: API Controller (Limited Actions)
* **Input:**
  ```
  rails g rails_hmvc:controller v1/posts --type=api --actions=index,show
  ```
* **Output:**
  * Controllers: 1
    * `app/controllers/v1/posts_controller.rb`
  * Operations: 2
    * `app/operations/v1/posts/index_operation.rb`
    * `app/operations/v1/posts/show_operation.rb`
  * Forms: 0 (no create/update actions)

### Test Case 2.4: API Controller (Custom Actions)
* **Input:**
  ```
  rails g rails_hmvc:controller v1/auth --type=api --actions=login,logout,register
  ```
* **Output:**
  * Controllers: 1
    * `app/controllers/v1/auth_controller.rb`
  * Operations: 3
    * `app/operations/v1/auth/login_operation.rb`
    * `app/operations/v1/auth/logout_operation.rb`
    * `app/operations/v1/auth/register_operation.rb`
  * Forms: 1
    * `app/forms/v1/auth/register_form.rb` (if register is considered a create action)

### Test Case 2.5: API Controller (Skip Operation)
* **Input:**
  ```
  rails g rails_hmvc:controller v1/categories --type=api --skip_operation
  ```
* **Output:**
  * Controllers: 1
    * `app/controllers/v1/categories_controller.rb`
  * Operations: 0
  * Forms: 2
    * `app/forms/v1/categories/create_form.rb`
    * `app/forms/v1/categories/update_form.rb`

### Test Case 2.6: API Controller (Skip Form)
* **Input:**
  ```
  rails g rails_hmvc:controller v1/tags --type=api --skip_form
  ```
* **Output:**
  * Controllers: 1
    * `app/controllers/v1/tags_controller.rb`
  * Operations: 5
    * `app/operations/v1/tags/index_operation.rb`
    * `app/operations/v1/tags/show_operation.rb`
    * `app/operations/v1/tags/create_operation.rb`
    * `app/operations/v1/tags/update_operation.rb`
    * `app/operations/v1/tags/destroy_operation.rb`
  * Forms: 0

### Test Case 2.7: API Controller (Skip Both)
* **Input:**
  ```
  rails g rails_hmvc:controller v1/comments --type=api --skip_operation --skip_form
  ```
* **Output:**
  * Controllers: 1
    * `app/controllers/v1/comments_controller.rb`
  * Operations: 0
  * Forms: 0

## 3. `operation` Generator

### Test Case 3.1: Single Operation
* **Input:**
  ```
  rails g rails_hmvc:operation v1/payments/process
  ```
* **Output:**
  * Operations: 1
    * `app/operations/v1/payments/process_operation.rb`

### Test Case 3.2: Multiple Operations
* **Input:**
  ```
  rails g rails_hmvc:operation v1/orders --actions=approve,reject,ship
  ```
* **Output:**
  * Operations: 3
    * `app/operations/v1/orders/approve_operation.rb`
    * `app/operations/v1/orders/reject_operation.rb`
    * `app/operations/v1/orders/ship_operation.rb`

### Test Case 3.3: Operation with Steps
* **Input:**
  ```
  rails g rails_hmvc:operation v1/checkout/complete --steps=validate,process_payment,create_order
  ```
* **Output:**
  * Operations: 1
    * `app/operations/v1/checkout/complete_operation.rb` (with 3 step methods inside)

## 4. `form` Generator

### Test Case 4.1: Single Form
* **Input:**
  ```
  rails g rails_hmvc:form v1/auth/login --attributes=email:string,password:string
  ```
* **Output:**
  * Forms: 1
    * `app/forms/v1/auth/login_form.rb` (with email and password attributes)

### Test Case 4.2: Multiple Forms
* **Input:**
  ```
  rails g rails_hmvc:form v1/products --actions=create,update --attributes=name:string,price:decimal,active:boolean
  ```
* **Output:**
  * Forms: 2
    * `app/forms/v1/products/create_form.rb` (with attributes)
    * `app/forms/v1/products/update_form.rb` (with attributes)

### Test Case 4.3: Simple Form (No Attributes)
* **Input:**
  ```
  rails g rails_hmvc:form v1/auth/logout
  ```
* **Output:**
  * Forms: 1
    * `app/forms/v1/auth/logout_form.rb` (with default name attribute)

## 5. Combination Tests

### Test Case 5.1: Complete Resource Generation
* **Input:**
  ```bash
  # Step 1: Initialize with API
  rails g rails_hmvc:init --type=api

  # Step 2: Generate controller
  rails g rails_hmvc:controller v1/articles --type=api

  # Step 3: Generate additional operations
  rails g rails_hmvc:operation v1/articles/publish --steps=validate,notify

  # Step 4: Generate custom form
  rails g rails_hmvc:form v1/articles/search --attributes=keyword:string,category_id:integer,published:boolean
  ```
* **Output:**
  * All files from individual components above
  * Properly structured directories
  * Consistent naming and inheritance
