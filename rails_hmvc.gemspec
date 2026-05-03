# frozen_string_literal: true

require_relative "lib/rails_hmvc/version"

Gem::Specification.new do |spec|
  spec.name = "rails_hmvc"
  spec.version = RailsHmvc::VERSION
  spec.authors = ["TOMOSIA VIETNAM"]
  spec.email = ["minh.tang1@tomosia.com", "anh.nguyen1@tomosia.com"]

  spec.summary = "Rails HMVC architecture implementation"
  spec.description = "A gem that provides HMVC architecture pattern for Rails applications with " \
                     "controllers, forms, operations, and serializers"
  spec.homepage = "https://github.com/TOMOSIA-VIETNAM/rails_hmvc"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/TOMOSIA-VIETNAM/rails_hmvc"
  spec.metadata["changelog_uri"] = "https://github.com/TOMOSIA-VIETNAM/rails_hmvc/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[
                        bin/ test/ spec/ features/ example/ docs/ memory-bank/
                        .git .github/ .circleci .cursor .DS_Store
                        gemfiles/
                      ]) ||
        f.match?(/\A(
          AGENTS\.md | CONTRIBUTING\.md | CODE_OF_CONDUCT\.md |
          \.rspec | \.rubocop\.yml | \.dockerignore |
          Appraisals | Dockerfile | docker-compose\.yml |
          Gemfile | Gemfile\.lock | Rakefile |
          appveyor
        )\z/x)
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "active_model_serializers", "~> 0.10.13"
  spec.add_dependency "rails", ">= 6.1"

  spec.add_development_dependency "generator_spec", "~> 0.10"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "rubocop-rails", "~> 2.19"
  spec.add_development_dependency "rubocop-rspec", "~> 2.22"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "sqlite3", ">= 1.4"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
