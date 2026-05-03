---
name: rails-hmvc-dev
description: Implement features for the Rails HMVC gem - generators, base classes, templates, and host-app components. Use when developing new generators, modifying templates, adding base classes, or implementing HMVC components (controllers, operations, forms, serializers).
---

# Rails HMVC Development

> Coding discipline principles (YAGNI, SRP, vertical slice, no hardcode, no mock bypass) are enforced by `.cursor/rules/mindset/coding_discipline.mdc` — always active on Ruby files.

## Before Starting

1. Read `.cursor/lessons/INDEX.md` — scan for lessons relevant to this task; read the individual lesson files that apply
2. Read `AGENTS.md` for project overview, structure, and conventions
3. Read `docs/en/architecture.md` to understand HMVC layers and request flow
4. Read `docs/en/components.md` for code patterns of each component type
5. Read existing source in `lib/generators/hmvc/` to understand current patterns
6. If the requirement is unclear, brainstorm with user first — do NOT guess

## Workflow (TDD - Strict)

Every implementation MUST follow this cycle. No exceptions.

RED → GREEN → REVIEW → DOCS → COMMIT

### Phase 1: RED (Write failing tests first)

1. Analyze the requirement
2. Create spec file(s) following the `rspec` skill patterns
3. Write tests covering success, failure, and edge cases
4. Run `bundle exec rspec {spec_file}` — confirm tests FAIL
5. Do NOT write any implementation code yet

### Phase 2: GREEN (Implement to pass)

1. Write the minimum code to make tests pass
2. Run `bundle exec rspec {spec_file}` — confirm all tests PASS
3. If tests fail, fix implementation (not tests) until green
4. Run `bundle exec rubocop {files}` — fix any style violations

### Phase 3: REVIEW (Code review via subagent)

1. Delegate to `code-reviewer` subagent to review all changed files
2. Fix any Critical or Warning issues found
3. Re-run `bundle exec rspec` after each fix — must stay green
4. Repeat until reviewer reports no Critical/Warning issues
5. If any Critical issue was found, invoke `lessons` subagent to record it

### Phase 4: DOCS (Update documentation if needed)

If the feature changes user-facing behavior (new generator, new option, new component pattern, changed config):

1. Identify which doc files need updating (getting-started, architecture, generators, components, testing)
2. Use the `docs` skill — write all three language versions (en, vi, ja)
3. Write documentation carefully — docs are for end users, not for you. Understand the content fully before writing. Do NOT patch together fragments.

### Phase 5: COMMIT

1. Read `.github/pull_request_template.md` to understand the commit message structure
2. Write commit message following that template's sections and format
3. Commit type prefix: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

## Component Rules (Quick Reference)

For full patterns and code examples, see `docs/en/components.md`.

**Controller** — HTTP only. Inherit `MainController`. Delegate to Operations. Use `render_collection` / `render_resource`. No business logic, no DB calls.

**Form** — Validate input. Inherit `MainForm`. Use `attribute` + `validates`. Call `valid!` to raise `Errors::ResourceError`. No DB interaction.

**Operation** — All business logic. Inherit `MainOperation`. Only public method: `call`. Break logic into `step_` private methods. Set `@result` for controller access.

**Serializer** — Format response. Inherit `MainSerializer`. Only `attributes` and associations. No logic.

**Error Handling** — Errors bubble from Operation to Controller. `Errorable` concern handles `rescue_from`. Use `Errors::ResourceError` for validation, `Errors::APIError` for custom status.

## Generator Development

For generator options and config reference, see `docs/en/generators.md`.

- Generators live in `lib/generators/hmvc/{name}/`
- Include `GeneratorHelpers` for config loading
- Init templates: `.tt` (Thor). Component templates: `.rb` (ERB)
- Controller generator invokes Operation and Form generators
- Register new generators in `lib/rails_hmvc.rb` Railtie block

## Naming Conventions

| What | Convention | Example |
|------|-----------|---------|
| Controller file | `{plural}_controller.rb` | `users_controller.rb` |
| Operation file | `{action}_operation.rb` | `create_operation.rb` |
| Form file | `{action}_form.rb` | `create_form.rb` |
| Serializer file | `{singular}_serializer.rb` | `user_serializer.rb` |

## Implementation Checklist

TDD Workflow:
- [ ] Phase 1: Write failing spec(s) — RED confirmed
- [ ] Phase 2: Implement code — GREEN confirmed
- [ ] Phase 3: Code review via code-reviewer subagent — issues fixed
- [ ] Phase 4: Docs updated if feature changes user-facing behavior
- [ ] Phase 5: Commit with PR template format

Code Quality:
- [ ] Component in correct directory with version namespace
- [ ] Inherits from correct parent class
- [ ] No business logic in controllers, no DB calls in forms
- [ ] Operations use step_ methods for complex logic
- [ ] RuboCop passes
