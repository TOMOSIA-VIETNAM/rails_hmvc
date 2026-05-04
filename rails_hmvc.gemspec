# frozen_string_literal: true

require_relative "lib/rails_hmvc/version"

Gem::Specification.new do |spec|
  spec.name = "rails_hmvc"
  spec.version = RailsHmvc::VERSION
  spec.authors = ["TOMOSIA VIETNAM", "Ruby Team"]
  spec.email = [
    "anh.nguyen1@tomosia.com",
    "minh.tang1@tomosia.com",
    "thuan.nguyen1@tomosia.com",
    "vu.nguyen@tomosia.com",
    "ho.nguyen@tomosia.com",
    "luan.dang2@tomosia.com"
  ]

  spec.summary = "HMVC for Rails—endpoints that absorbed every concern get boundaries again"
  spec.description = "Velocity feels free until each endpoint becomes a junk drawer: inputs, rules, " \
                     "data access, and responses tangled together, and tests only stay honest under full HTTP. " \
                     "Rails HMVC encodes one repeatable lifecycle across versioned APIs so teams stop paying " \
                     "interest on shortcuts. Maintained by TOMOSIA VIETNAM."
  spec.homepage = "https://github.com/TOMOSIA-VIETNAM/rails_hmvc"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/TOMOSIA-VIETNAM/rails_hmvc",
    "changelog_uri" => "https://github.com/TOMOSIA-VIETNAM/rails_hmvc/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/TOMOSIA-VIETNAM/rails_hmvc/issues",
    "documentation_uri" => "https://github.com/TOMOSIA-VIETNAM/rails_hmvc/tree/main/docs/en",
    "rubygems_mfa_required" => "true"
  }

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
  spec.executables = ["hmvc"]
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

  spec.metadata["rubygems_mfa_required"] = "true"
end
