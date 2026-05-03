# Contributing to Rails HMVC

Thank you for helping improve this gem. This document describes how the project is set up and what we expect from contributions.

## Prerequisites

- Ruby **>= 2.7** (see `rails_hmvc.gemspec` and `.rubocop.yml` `TargetRubyVersion`)
- Bundler compatible with `Gemfile.lock`
- Git (gemspec uses `git ls-files` for packaged files; Docker builds need `.git` in context)

## Getting started

```bash
git clone <repository-url>
cd rails_hmvc
docker compose up -d          # start dev container
docker compose exec dev bash  # exec in — all work happens here
```

## How to run checks (inside container)

```bash
bundle exec rake                    # full suite: RSpec + RuboCop (same as CI)
bundle exec rspec                   # tests + SimpleCov (always prints coverage %)
CI=true bundle exec rspec           # same + enforces minimum_coverage 100
bundle exec rubocop -A lib spec Rakefile rails_hmvc.gemspec  # lint + auto-correct
gem build rails_hmvc.gemspec        # build .gem
```

Source is volume-mounted — edits on host reflect immediately. Do not add `.git` to `.dockerignore`.

## Multi-version testing

The gem is validated against Ruby 2.7–3.3 × Rails 6.1–8.0. Use [Appraisals](https://github.com/thoughtbot/appraisal) to run specs under each Rails version.

```bash
# Generate or refresh gemfiles/ lockfiles (run once after updating Appraisals file)
bundle exec appraisal install

# Run specs against a specific Rails version
bundle exec appraisal rails-7-0 bundle exec rspec
bundle exec appraisal rails-7-1 bundle exec rspec
bundle exec appraisal rails-8-0 bundle exec rspec

# Full suite (rspec + rubocop) under one version
bundle exec appraisal rails-8-0 bundle exec rake
```

CI runs all supported combinations automatically (see `.github/workflows/main.yml`). The supported matrix:

| | Rails 6.1 | Rails 7.0 | Rails 7.1 | Rails 8.0 |
|-|-----------|-----------|-----------|-----------|
| Ruby 2.7 | ✓ | ✓ | ✓ | — |
| Ruby 3.0 | ✓ | ✓ | ✓ | — |
| Ruby 3.2 | — | ✓ | ✓ | ✓ |
| Ruby 3.3 | — | ✓ | ✓ | ✓ |

When writing new code, ensure specs pass on **all targeted combos** before opening a PR. If a combo is excluded, a comment in `main.yml` explains why.

## Project layout (quick reference)

| Path | Role |
|------|------|
| `lib/rails_hmvc.rb` | Entrypoint, Railtie, generator registration |
| `lib/generators/hmvc/` | Thor/Rails generators and templates |
| `lib/errors/` | Error classes shipped with the gem |
| `spec/dummy/` | Minimal Rails app used only to boot the framework in specs |
| `spec/rails_helper.rb` | Loads dummy app, generators, errors, `generator_spec` |

See [AGENTS.md](AGENTS.md) for a fuller map and HMVC flow in **host** applications.

## Pull requests

- Keep changes focused on one concern when possible.
- Run `bundle exec rake` locally; CI runs the same default task.
- Follow existing style (RuboCop; double-quoted strings per project config).
- If behavior visible to users changes (generators, options, config), update **all three** doc trees: `docs/en/`, `docs/vi/`, `docs/ja/` (see project rules / docs skill).

## Releasing a new version

1. Make sure `CHANGELOG.md` has entries under `[Unreleased]`
2. Set up your API key — pick one:
   - **`.env` file** (recommended): add `GEM_HOST_API_KEY=rubygems_xxx` to `.env`
   - **`~/.gem/credentials`**: run `gem signin` or add a named key manually
3. Run the release script:

```bash
bin/release 0.2.0              # uses GEM_HOST_API_KEY from .env
bin/release 0.2.0 -k mykey    # uses named key from ~/.gem/credentials
```

The script runs tests, lints, shows packaged files and release notes, then asks for confirmation before bumping the version, tagging, building, and pushing to RubyGems.

After the script completes:

```bash
git push origin main --tags
```

### Yanking a version

To remove a published version from RubyGems:

```bash
bin/yank 0.1.0              # uses GEM_HOST_API_KEY from .env
bin/yank 0.1.0 -k mykey    # uses named key from ~/.gem/credentials
```

This yanks the gem, removes the local git tag, and shows instructions for cleaning up the remote tag.

## Reporting issues

Include Ruby and Rails versions, the exact generator command and flags, and the relevant snippet of `config/rails_hmvc.yml` if applicable.

## Code of conduct

Contributors are expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

By contributing, you agree that your contributions will be licensed under the same terms as the project ([MIT License](LICENSE.txt)).
