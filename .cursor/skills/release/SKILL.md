---
name: rails-hmvc-release
description: Release a new version of the Rails HMVC gem. Handles version bump, CHANGELOG update, git tag, and gem build. Use when the user wants to release, publish, bump version, or tag a new gem version.
---

# Release

## Before Releasing

1. All changes committed — working directory must be clean
2. `CHANGELOG.md` — the `[Unreleased]` section must contain entries for this release
3. RubyGems API key — either `GEM_HOST_API_KEY` in `.env` or named key in `~/.gem/credentials`

## CHANGELOG Format

```markdown
## [Unreleased]

### Added
- New feature description

### Changed
- Existing behavior change

### Fixed
- Bug fix description

### Removed
- Removed feature

## [x.y.z] - YYYY-MM-DD

### Added
- ...
```

Categories: `Added`, `Changed`, `Fixed`, `Removed`, `Deprecated`, `Security`

When writing changelog entries:
- Write from the user's perspective, not the developer's
- Be specific about what changed and why it matters
- Reference generator names and CLI flags when relevant

## Version Strategy (Semver)

| Bump | When |
|------|------|
| **Major** (x.0.0) | Breaking changes to generated output, removed generators, config format changes |
| **Minor** (0.x.0) | New generators, new options, new template features |
| **Patch** (0.0.x) | Bug fixes, doc updates, template corrections |

## Release Workflow

**Use the script — it runs the full pipeline automatically:**

```bash
bin/release 1.2.0              # uses GEM_HOST_API_KEY from .env
bin/release 1.2.0 -k work     # uses named key from ~/.gem/credentials
```

The script runs these 6 steps in order, stopping on any failure:

| Step | What it does |
|------|-------------|
| 1/6 | `CI=true bundle exec rspec` — full test suite with coverage enforcement |
| 2/6 | `bundle exec rubocop` — lint check |
| 3/6 | Print all files that will be packaged in the `.gem` |
| 4/6 | Print release notes from `[Unreleased]` section of `CHANGELOG.md` |
| — | **Confirmation prompt** — review before proceeding |
| 5/6 | Bump `version.rb`, update `CHANGELOG.md`, git commit + tag |
| 6/6 | `gem build` → `gem push` (via `.env` or `-k`) → remove `.gem` artifact |

After the script completes, push commits and tags to remote:

```bash
git push origin main --tags
```

## Manual Steps (if script unavailable)

1. Run `CI=true bundle exec rspec` — must pass at 100% coverage
2. Run `bundle exec rubocop lib spec Rakefile rails_hmvc.gemspec` — must pass
3. Update `lib/rails_hmvc/version.rb`
4. Move `[Unreleased]` entries in `CHANGELOG.md` under new version header with today's date
5. `git commit -am "chore: release vX.Y.Z"`
6. `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
7. `gem build rails_hmvc.gemspec`
8. `gem push rails_hmvc-X.Y.Z.gem` (set `GEM_HOST_API_KEY` env var or use `-k key_name`)
9. `rm rails_hmvc-*.gem`
10. `git push origin main --tags`

## Gem Packaging

The gemspec intentionally excludes dev-only files. Only these are packaged:

- `lib/**` — all generator code, templates, error classes
- `sig/rails_hmvc.rbs` — type signatures
- `CHANGELOG.md`, `LICENSE.txt`, `README.md` — gem metadata

Excluded: `Gemfile`, `Rakefile`, `Dockerfile`, `docker-compose.yml`, `Appraisals`,
`gemfiles/`, `.rubocop.yml`, `CONTRIBUTING.md`, `AGENTS.md`, `spec/`, `bin/`, etc.

To verify what will be packaged before releasing:
```bash
ruby -e "puts Gem::Specification.load('rails_hmvc.gemspec').files"
```
