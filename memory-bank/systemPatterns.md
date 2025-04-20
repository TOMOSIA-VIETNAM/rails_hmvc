# System Patterns

## Architecture Overview

### HMVC Pattern Implementation
```
Request → Controller → Form → Operation → Model
                              ↓
Response ← Serializer ← Operation
```

## Component Architecture

### 1. Controllers
- Handle HTTP requests and responses
- Use Renderable and Errorable concerns
- Delegate to Operations for business logic
- No direct database calls
- Parameter wrapping disabled

### 2. Forms
- Inherit from ApplicationForm
- Include ActiveModel::Model and ActiveModel::Attributes
- Handle parameter validation
- Transform input data
- Provide clear error messages

### 3. Operations
- Inherit from ApplicationOperation
- Single public `call` interface
- Private `step_` methods for complex logic
- Handle business logic and database interactions
- Receive params and context through initialization

### 4. Serializers
- Inherit from ApplicationSerializer
- Format responses
- No business logic
- Consistent naming conventions

### 5. Error Handling
- Custom error inheritance hierarchy
- Standardized JSON error format
- Errorable concern implementation
- Resource-specific error handling

## Design Patterns

### 1. Single Responsibility Principle
- Each component has a specific role
- Clear separation of concerns
- Focused functionality

### 2. Dependency Injection
- Components receive dependencies through initialization
- Improved testability
- Reduced coupling

### 3. Builder Pattern
- Used for complex object construction
- Standardized component creation
- Clear initialization process

### 4. Command Pattern
- Operations implement command pattern
- Single public interface
- Encapsulated business logic

### 5. Serializer Pattern
- Consistent response formatting
- Separated presentation logic
- Versioned responses

## Component Relationships

### Version Namespace
```
v1/
  ├── controllers/
  ├── operations/
  ├── forms/
  └── serializers/
```

### Resource Organization
```
resource/
  ├── create_operation.rb
  ├── update_operation.rb
  ├── delete_operation.rb
  ├── create_form.rb
  └── update_form.rb
```

## Critical Implementation Paths

### 1. Request Flow
1. Route matches controller action
2. Controller validates parameters using Form
3. Controller delegates to Operation
4. Operation processes request
5. Controller renders response using Serializer

### 2. Error Handling Flow
1. Error occurs in any component
2. Error is caught and wrapped
3. Controller handles error through Errorable
4. Standardized error response returned

### 3. Validation Flow
1. Form receives parameters
2. Validation rules applied
3. Transformed data passed to Operation
4. Operation performs business validation
