---
description: Specification for Rails HMVC models
globs:
  - "app/models/**/*.rb"
alwaysApply: true
---

# Model Specification

The key words MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY are normative.

A Model is a persistence object. In HMVC the Model stays thin — use-case logic
lives in Operations, input rules in Forms. The Model describes data and the
relationships intrinsic to it.

## 1. Definition & Location

1.1. A Model MUST live under `app/models/`.

1.2. A Model SHOULD subclass `ApplicationRecord` (ActiveRecord) or follow the
     Mongoid equivalent.

## 2. Allowed Content

2.1. A Model SHOULD contain only:
     - associations (`has_many`, `belongs_to`, `has_one`, …),
     - persistence-level validations (uniqueness, NOT NULL, referential),
     - scopes,
     - enums,
     - lightweight, intrinsic persistence behavior.

2.2. Scopes MUST be query-only and side-effect free.

2.3. Enums and constants that describe the data SHOULD live on the Model.

## 3. Prohibited Content

3.1. A Model MUST NOT host use-case / workflow logic (orchestration, multi-step
     processes, external service calls, mailers, jobs). That belongs in an
     Operation.

3.2. A Model MUST NOT become a God Object. When a model accretes methods that
     coordinate other objects or implement business processes, move them to
     Operations.

3.3. A Model MUST NOT know about HTTP, controllers, Forms, or Serializers.

3.4. Heavy domain behavior MUST NOT be inlined; extract it (see §5).

## 4. Validations: Model vs Form

4.1. Two validation layers coexist by design:
     - **Form** validates *request input* (presence, format, allowed values for
       a given action) — the user-facing contract.
     - **Model** enforces *data integrity* that must hold regardless of entry
       point (uniqueness backed by a DB index, foreign-key presence, NOT NULL).

4.2. Input-shape rules that vary per action MUST live in the Form, not the Model.

4.3. Invariants that must never be violated in the database MUST be enforced at
     the Model (and ideally backed by a DB constraint).

## 5. Extracting Behavior

5.1. Reusable, model-intrinsic behavior SHOULD be extracted into
     `app/models/concerns`.

5.2. A concern MUST stay within the Model's remit (data + intrinsic behavior). A
     concern MUST NOT be a place to hide use-case logic that belongs in an
     Operation.

## 6. Callbacks

6.1. Lifecycle callbacks (`before_save`, `after_create`, …) SHOULD be limited to
     data-normalization concerns intrinsic to the record.

6.2. Callbacks MUST NOT trigger business workflows, external calls, mailers, or
     background jobs. Those MUST be invoked explicitly from an Operation step so
     the flow is visible and testable.

## 7. Persistence Ownership

7.1. Operations own when and how records are written. A Model exposes the
     standard persistence API (`create!`, `update!`, `save!`); the Operation
     decides the use case and wraps multi-write flows in a transaction.

7.2. Controllers and Serializers MUST NOT call Model persistence/query methods
     (see controllers.md §2.3, serializer.md §2.3).

## 8. Canonical Example

```ruby
# app/models/user.rb
# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :organization
  has_many   :posts, dependent: :destroy

  enum :role, { user: 'user', admin: 'admin' }

  validates :email, presence: true, uniqueness: true

  scope :admins, -> { where(role: 'admin') }
end
```

Note: `email` uniqueness is a data invariant (Model). Email *format* and the
`role` inclusion check for a request are input rules (Form). The act of creating
a user and sending a welcome email is a use case (Operation).
