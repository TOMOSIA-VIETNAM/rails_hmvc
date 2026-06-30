---
description: Rails HMVC architecture and conventions
globs:
  - "**/*.rb"
alwaysApply: true
---

# Rails HMVC

This project follows the Rails HMVC architecture provided by the `rails_hmvc` gem.

Always generate code that conforms to this architecture.

## Architecture

The application consists of five layers.

```
HTTP
 ↓
Controller
 ↓
Form
 ↓
Operation
 ↓
Model
 ↓
Serializer
 ↓
Response
```

Never bypass these layers.

---

# Controller

The controller is responsible only for HTTP.

Responsibilities

- Receive HTTP requests.
- Instantiate Forms.
- Call Operations.
- Render responses.
- Return HTTP status codes.

Controllers must NOT

- Execute business logic.
- Query ActiveRecord directly.
- Perform validations.
- Transform JSON manually.

---

# Form

Forms validate and normalize request parameters.

Responsibilities

- Validate user input.
- Convert parameters into domain-friendly values.
- Raise validation errors when input is invalid.

Forms must NOT

- Save records.
- Execute business logic.
- Perform database queries.
- Render responses.

---

# Operation

Operations contain all business logic.

Responsibilities

- Execute use cases.
- Read/write models.
- Manage transactions.
- Call external services.

Operations must NOT

- Access HTTP request objects.
- Render JSON.
- Know about controllers.

Business rules always belong here.

---

# Model

Models are persistence objects.

Models should contain only

- Associations
- Validations
- Scopes
- Lightweight persistence behavior

Models must NOT become God Objects.

Move business workflows into Operations.

---

# Serializer

Serializers define API output.

Responsibilities

- Serialize resources.
- Serialize collections.
- Format JSON responses.

Serializers must NOT

- Execute queries.
- Execute business logic.

---

# Error Handling

Use the standardized error handling provided by rails_hmvc.

Do not implement custom JSON error structures unless explicitly requested.

---

# Code Generation

When implementing a new API resource:

1. Generate the controller.
2. Generate Forms.
3. Generate Operations.
4. Generate Serializer.
5. Wire everything together following HMVC.

Prefer using the rails_hmvc generators whenever possible.

---

# General Rules

Always prefer consistency over creativity.

Do not introduce new architectural layers unless explicitly requested.

Do not place business logic in Controllers or Models.

Every responsibility must belong to exactly one layer.

When unsure, put business logic into an Operation.
