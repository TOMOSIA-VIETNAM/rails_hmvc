# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-05-04

### Added

- **HMVC architecture for Rails** — enforce separation of concerns with 5 layers: Controller (HTTP), Form (validation), Operation (business logic), Serializer (output), and Error (standardized handling)
- **One-command scaffolding** — `rails g rails_hmvc:controller v1/users --type=api` generates a full resource: controller, 5 operations (index/show/create/update/destroy), and 2 forms — all wired up and following the same pattern
- **Project initialization** — `rails g rails_hmvc:init` sets up the entire HMVC directory structure, base classes, and configuration in seconds
- **Versioned API support** — built-in namespace versioning (`v1/`, `v2/`) so breaking changes never leak into production
- **Standalone generators** — generate operations (`rails_hmvc:operation`) and forms (`rails_hmvc:form`) independently for fine-grained control
- **YAML-driven configuration** — customize parent classes, project type (API/Web), and version namespaces via `config/rails_hmvc.yml`
- **Multilingual documentation** — full guides in English, Vietnamese, and Japanese
