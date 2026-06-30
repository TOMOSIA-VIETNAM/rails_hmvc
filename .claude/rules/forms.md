---
description: Specification for Rails HMVC forms
globs:
  - "app/forms/**/*.rb"
alwaysApply: true
---

# Form Specification

The key words MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY are normative.

A Form validates and normalizes input parameters into trusted attributes. It is
a pure input contract — no persistence, no side effects.

## 1. Definition & Location

1.1. A Form MUST live under `app/forms/{version}/{resource}/`.
     Example: `app/forms/v1/users/create_form.rb`.

1.2. The class MUST be namespaced and named `{Action}Form`.
     Example: `class V1::Users::CreateForm < MainForm`.

1.3. A Form MUST subclass `MainForm`.

1.4. `MainForm` includes `ActiveModel::Model`, `::Attributes`, `::Validations`,
     and `::Validations::Callbacks`. A Form MUST rely on these rather than
     reimplementing them.

## 2. Responsibilities

2.1. A Form MUST:
     - declare its accepted fields with `attribute`,
     - validate those fields with `ActiveModel::Validations`,
     - normalize/coerce input (via attribute types and callbacks).

2.2. A Form MUST NOT touch the database (no queries, no saves, no `find`).
     The one allowed exception is a custom validator that performs a read-only
     uniqueness/existence check; such logic SHOULD live in a reusable validator
     class, not inline.

2.3. A Form MUST NOT contain business logic. Decisions about *what happens* with
     valid data belong to the Operation.

2.4. A Form MUST NOT render or know about HTTP.

2.5. A Form MUST NOT call external services or perform outbound HTTP.

## 3. Declaring Attributes

3.1. Every accepted field MUST be declared:
```ruby
attribute :email,    :string
attribute :password, :string
attribute :role,     :string, default: 'user'
```

3.2. Use typed attributes for coercion. A field with no declared type accepts the
     raw value; prefer an explicit type.

3.3. Defaults SHOULD be expressed with `default:` rather than in validations or
     the Operation.

## 4. Validation

4.1. Validation MUST use standard `validates` declarations:
```ruby
validates :email,    presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
validates :password, presence: true, length: { minimum: 8 }
validates :role,     inclusion: { in: %w[user admin] }
```

4.2. Reusable rules (e.g. strong password, uniqueness) SHOULD be extracted into
     custom validator classes (see `app/validators`).

4.3. Conditional validation MAY use `if:`/`unless:`/`on:` but MUST NOT branch on
     business state fetched from the database.

## 5. Contract: `valid!` and `attributes`

5.1. A Form is consumed inside an Operation. The Operation MUST call `valid!`:
```ruby
@form = V1::Users::CreateForm.new(params)
@form.valid!   # raises Errors::ResourceError when invalid
```

5.2. `valid!` returns `self` on success and raises
     `Errors::ResourceError.new(resource: self, message: errors.full_messages)`
     on failure. A Form MUST NOT override this contract.

5.3. Validated data MUST be read via `attributes`, which returns a
     symbol-keyed Hash:
```ruby
@form.attributes  # => { email: "...", password: "...", role: "user" }
```

5.4. The Operation MUST pass `@form.attributes` to persistence, not the raw
     `params`. This is the trust boundary.

## 6. Error Behavior

6.1. A Form MUST NOT rescue its own validation errors. `valid!` raises; the
     Operation lets it propagate; `Errorable` maps `Errors::ResourceError` to
     422. Do not short-circuit this chain.

## 7. Canonical Example

```ruby
# app/forms/v1/users/create_form.rb
# frozen_string_literal: true

class V1::Users::CreateForm < MainForm
  attribute :email,    :string
  attribute :password, :string
  attribute :name,     :string
  attribute :role,     :string, default: 'user'

  validates :email,    presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }
  validates :name,     presence: true
  validates :role,     inclusion: { in: %w[user admin] }
end
```

## 8. Form per Action

8.1. Forms are per-action. `create` and `update` MUST have separate Forms even
     when fields overlap, because their rules diverge (e.g. password optional on
     update). Default generated actions are `create` and `update` (plus `new`,
     `edit` for web).

8.2. Shared declarations MAY be factored into a parent Form or a concern, but the
     concrete per-action class MUST remain.

## 9. Generation

```
hmvc g form v1/user --actions=create,update --attributes=email:string,name:string
```
The generator creates one `{Action}Form` per action under the resource folder.
