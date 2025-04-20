# Technical Context

## Technology Stack

### Core Technologies
- Ruby 3.2.0
- Rails 8.0.2
- RSpec for testing
- Rubocop for code quality

### Key Dependencies
- active_model_serializers (0.10.15)
- zeitwerk (2.7.2)
- rake (13.2.1)

## Development Setup

### Environment Requirements
- Ruby 3.2.0+
- Bundler
- Git

### Installation
```bash
# Add to Gemfile
gem 'rails_hmvc'

# Install
bundle install
```

### Configuration
- `rails_hmvc.yml` for project configuration
- Environment variables through `.env` files
- RSpec configuration for testing
- Rubocop configuration for linting

## Technical Constraints

### Code Organization
- Maximum file size: 300 lines
- Strict directory structure
- Versioned components
- Standardized naming conventions

### Performance Considerations
- Minimal middleware usage
- Efficient request handling
- Optimized database queries
- Proper caching strategies

### Security Requirements
- No sensitive data in logs
- Proper authentication/authorization
- Input validation
- Secure parameter handling

## Tool Usage Patterns

### Generator Commands
```bash
# Generate new component
rails g hmvc:init

# Generate controller
rails g hmvc:controller

# Generate operation
rails g hmvc:operation

# Generate form
rails g hmvc:form
```

### Testing Tools
- RSpec for unit tests
- Factory Bot for test data
- Database Cleaner
- SimpleCov for coverage

### Code Quality Tools
- Rubocop for style checking
- Brakeman for security
- Bundle Audit for dependencies
- RSpec for test coverage

## Development Workflow

### 1. Setup
1. Install dependencies
2. Configure environment
3. Run initial setup
4. Configure testing environment

### 2. Development
1. Generate components
2. Implement features
3. Write tests
4. Run quality checks

### 3. Testing
1. Unit tests
2. Integration tests
3. Code coverage
4. Security checks

### 4. Deployment
1. Quality checks
2. Security audit
3. Documentation update
4. Version management
