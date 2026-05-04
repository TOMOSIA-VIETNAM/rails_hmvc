# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2026-05-04

### Added

- **Standalone CLI** — `exe/hmvc` binary wraps Rails generators with a shorter interface (`hmvc init`, `hmvc g controller v1/users`, `hmvc d controller v1/users`)
- **Destroy support** — remove generated files with `hmvc d <generator> <name>` or `rails d hmvc:<generator>`
- **GitHub issue templates** — bug report and feature request forms for easier contribution
- **Dependabot configuration** — automated dependency updates for Bundler and GitHub Actions

### Changed

- **Shorter generator namespace** — renamed from `rails_hmvc:*` to `hmvc:*` (legacy names still work)
- Rewrote gem summary and description to focus on the problem being solved, not component listing
- Added additional gem metadata (bug tracker, documentation URI, MFA required)
- Expanded author list to full Ruby Team
- Dependabot now groups minor/patch updates, uses `Asia/Ho_Chi_Minh` timezone, and auto-labels PRs
- `bin/release` supports two-phase workflow: `--prepare` (agent) then `--deploy` (human enters OTP)
- GitHub issue templates rewritten with project-specific placeholders (replaced factory_bot defaults)
- Documentation updated across all languages (EN/VI/JA) to reflect new CLI and generator names

## [0.1.1] - 2026-05-04

### Fixed

- Corrected gem metadata URLs (homepage, source code, changelog)

## [0.1.0] - 2026-05-04 [YANKED]

### Added

- **HMVC architecture for Rails** — enforce separation of concerns with 5 layers: Controller (HTTP), Form (validation), Operation (business logic), Serializer (output), and Error (standardized handling)
- **One-command scaffolding** — `rails g hmvc:controller v1/users --type=api` generates a full resource: controller, 5 operations (index/show/create/update/destroy), and 2 forms — all wired up and following the same pattern
- **Project initialization** — `rails g hmvc:init` sets up the entire HMVC directory structure, base classes, and configuration in seconds
- **Versioned API support** — built-in namespace versioning (`v1/`, `v2/`) so breaking changes never leak into production
- **Standalone generators** — generate operations (`hmvc:operation`) and forms (`hmvc:form`) independently for fine-grained control
- **YAML-driven configuration** — customize parent classes, project type (API/Web), and version namespaces via `config/rails_hmvc.yml`
- **Multilingual documentation** — full guides in English, Vietnamese, and Japanese
