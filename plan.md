# Implementation Plan

## Phase 1: Core Structure & Base Components ✅

- [x] Task 1: Initialize the `rails-hmvc` gem project structure.
- [x] Task 2: Implement `Rails::Hmvc::Controllers::ApplicationController` with `Renderable` and `Errorable` concerns.
    - [x] Define `Renderable` concern.
    - [x] Define `Errorable` concern.
- [x] Task 3: Implement `Rails::Hmvc::Forms::ApplicationForm` with `ActiveModel` integration and `valid!` method.
- [x] Task 4: Implement `Rails::Hmvc::Operations::ApplicationOperation` with `call` interface and initialization logic.
- [x] Task 5: Implement `Rails::Hmvc::Serializers::ApplicationSerializer` inheriting from `ActiveModel::Serializer`.
- [x] Task 6: Implement `Rails::Hmvc::Errors::ExceptionError` module for standard error definitions.
- [x] Task 7: Implement `Rails::Hmvc::Errors::ResourceError` class for formatting errors, including `ExceptionError`.
- [x] Task 8: Define the base directory structure (`lib/rails/hmvc/...`) for the gem.
- [x] Task 9: Set up initial gem dependencies (`gemspec`).

## Phase 2: Generators and CLI 🚧

- [ ] Task 10: Implement the `rails g hmvc:init` generator.
    - [ ] Create generator class in `lib/generators/hmvc/init`
    - [ ] Add directory creation logic
    - [ ] Add configuration file template
    - [ ] Add application.rb modification logic
    - [ ] Add test files

- [ ] Task 11: Implement the `rails g hmvc:resources` generator.
    - [ ] Create generator class in `lib/generators/hmvc/resources`
    - [ ] Add argument parsing
    - [ ] Add template files for each component
    - [ ] Add route injection logic
    - [ ] Add test files

- [ ] Task 12: Implement the `rails g hmvc:operation` generator.
    - [ ] Create generator class
    - [ ] Add operation templates
    - [ ] Add test files

- [ ] Task 13: Implement the `rails g hmvc:form` generator.
    - [ ] Create generator class
    - [ ] Add form templates
    - [ ] Add test files

- [ ] Task 14: Implement the `rails g hmvc:controller` generator.
    - [ ] Create generator class
    - [ ] Add controller templates
    - [ ] Add test files

- [ ] Task 15: Create templates for generated files.
    - [ ] Controller templates
    - [ ] Operation templates
    - [ ] Form templates
    - [ ] Route templates
    - [ ] Test templates

## Phase 3: Configuration 📝

- [ ] Task 16: Implement loading and parsing of `config/rails_hmvc.yml`.
    - [ ] Create configuration class
    - [ ] Add YAML parsing
    - [ ] Add validation
    - [ ] Add default values

- [ ] Task 17: Ensure CLI flags override YAML configuration settings.
    - [ ] Add flag parsing
    - [ ] Add override logic
    - [ ] Add validation

## Phase 4: Testing 🧪

- [ ] Task 18: Set up RSpec.
    - [ ] Add RSpec configuration
    - [ ] Add test helpers
    - [ ] Add shared examples

- [ ] Task 19: Write unit tests for all base classes.
    - [ ] ApplicationController specs
    - [ ] ApplicationForm specs
    - [ ] ApplicationOperation specs
    - [ ] ApplicationSerializer specs

- [ ] Task 20: Write unit tests for concerns.
    - [ ] Renderable specs
    - [ ] Errorable specs

- [ ] Task 21: Write unit tests for error classes.
    - [ ] ExceptionError specs
    - [ ] ResourceError specs

- [ ] Task 22: Write tests for all generators.
    - [ ] Init generator specs
    - [ ] Resources generator specs
    - [ ] Operation generator specs
    - [ ] Form generator specs
    - [ ] Controller generator specs

- [ ] Task 23: Write integration tests.
    - [ ] Full request flow specs
    - [ ] Generator integration specs
    - [ ] Configuration integration specs

## Phase 5: Documentation & Examples 📚

- [ ] Task 24: Write `README.md`.
    - [ ] Installation guide
    - [ ] Configuration guide
    - [ ] Usage examples
    - [ ] Best practices

- [ ] Task 25: Document all CLI commands.
    - [ ] Command reference
    - [ ] Option reference
    - [ ] Examples

- [ ] Task 26: Provide example Rails application.
    - [ ] Basic CRUD example
    - [ ] Authentication example
    - [ ] Complex workflow example

- [ ] Task 27: Document conventions.
    - [ ] Controller conventions
    - [ ] Operation conventions
    - [ ] Form conventions
    - [ ] Model conventions
    - [ ] Serializer conventions
    - [ ] Error handling conventions

- [ ] Task 28: Add YARD comments.
    - [ ] Document public methods
    - [ ] Document class purposes
    - [ ] Add usage examples

## Future Enhancements (Post-MVP) 🚀

- [ ] Task 29: Integrate RuboCop for HMVC structure conventions.
- [ ] Task 30: Explore model layer extensions for pagination.
- [ ] Task 31: Investigate GraphQL schema generation support.
- [ ] Task 32: Define best practices for custom middleware integration.
