**Phase 1: Core Structure & Base Components**

-   [ ] Task 1: Initialize the `rails-hmvc` gem project structure.
-   [ ] Task 2: Implement `Rails::Hmvc::Controllers::ApplicationController` with `Renderable` and `Errorable` concerns.
    -   [ ] Define `Renderable` concern.
    -   [ ] Define `Errorable` concern.
-   [ ] Task 3: Implement `Rails::Hmvc::Forms::ApplicationForm` with `ActiveModel` integration and `valid!` method.
-   [ ] Task 4: Implement `Rails::Hmvc::Operations::ApplicationOperation` with `call` interface and initialization logic.
-   [ ] Task 5: Implement `Rails::Hmvc::Serializers::ApplicationSerializer` inheriting from `ActiveModel::Serializer`.
-   [ ] Task 6: Implement `Rails::Hmvc::Errors::ExceptionError` module for standard error definitions.
-   [ ] Task 7: Implement `Rails::Hmvc::Errors::ResourceError` class for formatting errors, including `ExceptionError`.
-   [ ] Task 8: Define the base directory structure (`lib/rails/hmvc/...`) for the gem.
-   [ ] Task 9: Set up initial gem dependencies (`gemspec`).

**Phase 2: Generators and CLI**

-   [ ] Task 10: Implement the `rails g hmvc:init` generator.
    -   [ ] Create necessary directories (`app/controllers`, `app/operations`, `app/forms`).
    -   [ ] Add HMVC configuration loading to `config/application.rb`.
-   [ ] Task 11: Implement the `rails g hmvc:resources` generator.
    -   [ ] Parse arguments (`--resources`, `--type`, `--parent-*`, `--skip-routes`).
    -   [ ] Generate controller file based on templates.
    -   [ ] Generate operation files (index, show, create, update, destroy) based on templates.
    -   [ ] Generate form files (index, show, create, update, destroy) based on templates.
    -   [ ] Implement logic to update `config/routes.rb` (unless `--skip-routes=true`).
    -   [ ] Read defaults from `rails_hmvc.yml`.
-   [ ] Task 12: Implement the `rails g hmvc:operation` generator.
    -   [ ] Parse arguments (`--resources`, `--resource`, `--type`, `--parent`).
    -   [ ] Implement logic to generate single or multiple operation files based on templates.
    -   [ ] Read defaults from `rails_hmvc.yml`.
-   [ ] Task 13: Implement the `rails g hmvc:form` generator.
    -   [ ] Parse arguments (`--resources`, `--resource`, `--type`, `--parent`).
    -   [ ] Implement logic mirroring `hmvc:operation` for form generation.
    -   [ ] Read defaults from `rails_hmvc.yml`.
-   [ ] Task 14: Implement the `rails g hmvc:controller` generator.
    -   [ ] Parse arguments (`--resources`, `--type`, `--parent`).
    -   [ ] Generate controller file with standard RESTful actions based on templates.
    -   [ ] Read defaults from `rails_hmvc.yml`.
-   [ ] Task 15: Create templates for generated files (controllers, operations, forms).

**Phase 3: Configuration**

-   [ ] Task 16: Implement loading and parsing of `config/rails_hmvc.yml`.
-   [ ] Task 17: Ensure CLI flags override YAML configuration settings.

**Phase 4: Testing**

-   [ ] Task 18: Set up RSpec (or chosen testing framework).
-   [ ] Task 19: Write unit tests for all base classes (`ApplicationController`, `ApplicationForm`, `ApplicationOperation`, `ApplicationSerializer`).
-   [ ] Task 20: Write unit tests for `Errorable` and `Renderable` concerns.
-   [ ] Task 21: Write unit tests for error classes (`ExceptionError`, `ResourceError`).
-   [ ] Task 22: Write tests for all generators (`init`, `resources`, `operation`, `form`, `controller`).
    -   [ ] Verify correct file creation and content.
    -   [ ] Verify route injection logic.
    -   [ ] Verify handling of CLI arguments and YAML configuration.
-   [ ] Task 23: Write integration tests covering the request flow (Controller -> Form -> Operation -> Serializer).

**Phase 5: Documentation & Examples**

-   [ ] Task 24: Write `README.md` including installation, configuration, and usage guides.
-   [ ] Task 25: Document all CLI commands and their options.
-   [ ] Task 26: Provide a complete example Rails application demonstrating HMVC usage.
-   [ ] Task 27: Document conventions for each layer (Controller, Operation, Form, Model, Serializer, Error).
-   [ ] Task 28: Add YARD comments to public classes and methods in the gem code.

**Future Enhancements (Post-MVP)**

-   [ ] Task 29: Integrate RuboCop for HMVC structure conventions (Section 10).
-   [ ] Task 30: Explore model layer extensions for pagination (Section 9).
-   [ ] Task 31: Investigate GraphQL schema generation support (Section 9).
-   [ ] Task 32: Define best practices for custom middleware integration (Section 9).
