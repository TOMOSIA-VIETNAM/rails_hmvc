# Rails HMVC Testing Script

## Progress Log

### 2024-03-XX
- [x] Initial setup attempt
- [x] Encountered and fixed gemspec error
  - Issue: Invalid gemspec with self-inclusion error
  - Solution: Updated spec.files to explicitly list required files
  - Status: ✅ Fixed
- [x] Discovered generator namespace issue
  - Issue: Generators registered with `rails_hmvc:` namespace instead of `hmvc:`
  - Solution: Use `rails g rails_hmvc:init` instead of `rails g hmvc:init`
  - Status: ✅ Fixed
- [x] Successfully initialized HMVC structure
  - Created base directories and files
  - Added routes and base classes
  - Generated configuration file
  - Status: ✅ Completed

## Introduction

This document outlines the manual testing process for verifying the functionality of the rails_hmvc gem. It provides a step-by-step approach to testing each feature, from installation to the creation of complex components.

## Testing Environment Setup

- [x] Fresh Rails project setup
  - [x] Create a new directory for testing: `mkdir rails_hmvc_test`
  - [x] Initialize a new Rails API application: `rails new rails_hmvc_test --api`
  - [x] Add the rails_hmvc gem to Gemfile: `gem 'rails_hmvc', path: '../rails_hmvc'`
  - [x] Run `bundle install` (Successfully completed)

### Gemspec Configuration
Before proceeding with testing, ensure gemspec is properly configured:

1. Verify gemspec content:
   ```ruby
   spec.files = Dir[
     "lib/**/*",
     "LICENSE.txt",
     "README.md",
     "CHANGELOG.md"
   ]
   ```

2. Required files checklist:
   - [x] lib/rails_hmvc.rb exists
   - [x] lib/rails_hmvc/version.rb exists
   - [x] LICENSE.txt exists
   - [x] README.md exists
   - [x] CHANGELOG.md exists

## Test 1: Basic Installation and Initialization

- [x] Test the initialization generator
  ```bash
  rails g rails_hmvc:init
  ```

- [x] Verify the following files/directories are created:
  - [x] `config/rails_hmvc.yml` file
  - [x] Application-level base classes:
    - [x] `app/controllers/application_controller.rb` (or modifications to existing)
    - [x] `app/operations/application_operation.rb`
    - [x] `app/forms/application_form.rb`
    - [x] `app/serializers/application_serializer.rb`
  - [x] Directory structure:
    - [x] `app/operations/`
    - [x] `app/forms/`
    - [x] `app/serializers/`
    - [x] `lib/errors/`
  - [x] Error handling files:
    - [x] `lib/errors/application_error.rb`
    - [x] `lib/errors/resource_error.rb`
  - [x] Controller concerns:
    - [x] `app/controllers/concerns/renderable.rb`
    - [x] `app/controllers/concerns/errorable.rb`

## Test 2: Configuration File Validation

- [x] Verify content of `config/rails_hmvc.yml`:
  - [x] Correct structure with type, parent classes, and versioning
  - [x] Valid YAML syntax
  - [x] Appropriate default values

## Test 3: Resources Generator (Complete Resource Set)

- [ ] Generate a complete resource
  ```bash
  rails g rails_hmvc:resources users
  ```

- [ ] Verify generated files:
  - [ ] Controller:
    - [ ] `app/controllers/v1/users_controller.rb`
  - [ ] Operations:
    - [ ] `app/operations/v1/users/index_operation.rb`
    - [ ] `app/operations/v1/users/show_operation.rb`
    - [ ] `app/operations/v1/users/create_operation.rb`
    - [ ] `app/operations/v1/users/update_operation.rb`
    - [ ] `app/operations/v1/users/destroy_operation.rb`
  - [ ] Forms:
    - [ ] `app/forms/v1/users/create_form.rb`
    - [ ] `app/forms/v1/users/update_form.rb`
  - [ ] Serializer:
    - [ ] `app/serializers/v1/user_serializer.rb`
  - [ ] Routes:
    - [ ] Check `config/routes.rb` for added routes with namespace

- [ ] Validate file content:
  - [ ] Proper inheritance from base classes
  - [ ] Correct namespacing
  - [ ] Standard RESTful methods in controllers
  - [ ] Proper integration between components

## Test 4: Individual Generator Tests

### Controller Generator Test

- [ ] Generate a controller with custom actions
  ```bash
  rails g rails_hmvc:controller posts --actions=index,show,create,update,destroy
  ```

- [ ] Verify:
  - [ ] `app/controllers/v1/posts_controller.rb` is created
  - [ ] Contains only specified actions
  - [ ] Inherits from appropriate parent class
  - [ ] Includes proper concerns

### Operation Generator Test

- [ ] Generate an operation with custom steps
  ```bash
  rails g rails_hmvc:operation posts/create --steps=validate,create_post,notify_admin
  ```

- [ ] Verify:
  - [ ] `app/operations/v1/posts/create_operation.rb` is created
  - [ ] Contains specified step methods
  - [ ] Proper call method implementation

### Form Generator Test

- [ ] Generate a form with attributes and validations
  ```bash
  rails g rails_hmvc:form posts/create --attributes title:string content:text published:boolean --validations title:presence:true,content:length:{minimum:10}
  ```

- [ ] Verify:
  - [ ] `app/forms/v1/posts/create_form.rb` is created
  - [ ] Contains specified attributes
  - [ ] Contains specified validations
  - [ ] Proper valid! method implementation

### Serializer Generator Test

- [ ] Generate a serializer with attributes
  ```bash
  rails g rails_hmvc:serializer post --attributes id:integer title:string content:text created_at:datetime
  ```

- [ ] Verify:
  - [ ] `app/serializers/v1/post_serializer.rb` is created
  - [ ] Contains specified attributes

## Test 5: Configuration Override Tests

- [ ] Test CLI option overrides:
  - [ ] Generate with different version:
    ```bash
    rails g rails_hmvc:controller comments --version=v2
    ```
  - [ ] Generate with custom parent:
    ```bash
    rails g rails_hmvc:operation comments/create --parent=CustomOperation
    ```

- [ ] Verify:
  - [ ] CLI options correctly override defaults
  - [ ] Generated files reflect specified options

## Test 6: Edge Cases

- [ ] Test with nested resources:
  ```bash
  rails g rails_hmvc:resources posts/comments
  ```

- [ ] Test with singular resource:
  ```bash
  rails g rails_hmvc:resources profile --singular
  ```

- [ ] Test with custom namespace:
  ```bash
  rails g rails_hmvc:resources admin/users --version=admin
  ```

- [ ] Verify all edge cases work correctly and generate appropriate files/paths

## Test 7: Functionality Verification

- [ ] Create a basic model:
  ```bash
  rails g model User name:string email:string
  rails db:migrate
  ```

- [ ] Add implementations to generated components:
  - [ ] Implement creation logic in operations
  - [ ] Add validations to forms
  - [ ] Configure controller to use operations
  - [ ] Add attributes to serializer

- [ ] Start Rails server:
  ```bash
  rails server
  ```

- [ ] Test API endpoints using curl or Postman:
  - [ ] GET /v1/users
  - [ ] POST /v1/users with valid data
  - [ ] POST /v1/users with invalid data (validate error handling)
  - [ ] GET /v1/users/:id
  - [ ] PUT /v1/users/:id
  - [ ] DELETE /v1/users/:id

## Test 8: Multiversion Testing

- [ ] Create v2 components using generators:
  ```bash
  rails g rails_hmvc:resources users --version=v2
  ```

- [ ] Make differences in v2 implementation
- [ ] Verify both v1 and v2 endpoints work correctly

## Regression Testing

- [ ] Verify gem doesn't interfere with standard Rails functionality
- [ ] Verify existing code is not affected by gem installation
- [ ] Test backwards compatibility with different Rails versions

## Conclusion and Reporting

Upon completion of the tests, document the following:

- Any issues encountered
- Aspects that worked well
- Suggestions for improvement
- Overall assessment of gem functionality

## Test Completion Checklist

- [ ] All tests passed
- [ ] Edge cases handled properly
- [ ] Documentation matches actual behavior
- [ ] Error messages are helpful and clear
- [ ] Generated code follows best practices
- [ ] Gem can be used in a real project
