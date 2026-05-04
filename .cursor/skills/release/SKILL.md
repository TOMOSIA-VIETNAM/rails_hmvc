---
name: rails-hmvc-release
description: Release a new version of the Rails HMVC gem. Handles version bump, CHANGELOG update, git tag, and gem build. Use when the user wants to release, publish, bump version, or tag a new gem version.
---

# Release

## Before Releasing

1. All changes committed — working directory must be clean
2. `CHANGELOG.md` — must have a `## [x.y.z] - YYYY-MM-DD` section with entries for this release
3. RubyGems API key — either `GEM_HOST_API_KEY` in `.env` or named key in `~/.gem/credentials`

## CHANGELOG Format

```markdown
## [x.y.z] - YYYY-MM-DD

### Added
- New feature description

### Changed
- Existing behavior change

### Fixed
- Bug fix description

### Removed
- Removed feature

## [older] - YYYY-MM-DD

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

### Two-phase release (recommended — agent + human)

RubyGems requires OTP for `gem push`, so the release is split into two phases:

**Phase 1 — Agent runs `--prepare`** (automated, no OTP needed):

```bash
bin/release 1.2.0 --prepare
```

This runs steps 1–6 below but **stops after `gem build`** without pushing:

| Step | What it does |
|------|-------------|
| 1/6 | `CI=true bundle exec rspec` — full test suite with coverage enforcement |
| 2/6 | `bundle exec rubocop` — lint check |
| 3/6 | Print all files that will be packaged in the `.gem` |
| 4/6 | Print release notes for the target version from `CHANGELOG.md` |
| — | **Confirmation prompt** — review before proceeding |
| 5/6 | Bump `version.rb`, git commit + tag |
| 6/6 | `gem build` — produces `.gem` file, does **not** push |

After `--prepare` completes, the agent should tell the user to run:

**Phase 2 — Human runs `--deploy`** (prompts for OTP, pushes gem + git tags + creates GitHub Release):

```bash
bin/release 1.2.0 --deploy
```

The `--deploy` step automatically:
1. Prompts for OTP, pushes gem to RubyGems
2. Pushes commits + tags (detects `.cursor/remote` for temp-remote environments)
3. Creates a GitHub Release with notes from `CHANGELOG.md` (requires `gh` CLI)

### Full release (when OTP is not required)

```bash
bin/release 1.2.0              # uses GEM_HOST_API_KEY from .env
bin/release 1.2.0 -k work     # uses named key from ~/.gem/credentials
```

Runs all 6 steps including `gem push`, then prints instructions to push git tags and create release.

### Yanking a version

```bash
bin/yank 0.1.0              # uses GEM_HOST_API_KEY from .env
bin/yank 0.1.0 -k work     # uses named key from ~/.gem/credentials
```

## Git Remote: no-remote environments

When `.cursor/remote` exists in the project root, the repo has **no persistent `git remote`** (security policy). The deploy script detects this and uses `~/.shared/scripts/git-temp-remote.zsh` (which must be sourced in `~/.zshrc`) to push via a temporary remote.

- `.cursor/remote` contains the remote URL (e.g. `git@github.com:TOMOSIA-VIETNAM/rails_hmvc.git`)
- The script adds a temp remote, pushes, then removes it immediately
- On devices with a normal `git remote origin`, this is ignored — standard `git push` is used

## Manual Steps (if script unavailable)

1. Run `CI=true bundle exec rspec` — must pass at 100% coverage
2. Run `bundle exec rubocop lib spec Rakefile rails_hmvc.gemspec` — must pass
3. Update `lib/rails_hmvc/version.rb`
4. Add version entry in `CHANGELOG.md` with `## [x.y.z] - YYYY-MM-DD` header
5. `git commit -am "chore: release vX.Y.Z"`
6. `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
7. `gem build rails_hmvc.gemspec`
8. `gem push rails_hmvc-X.Y.Z.gem --otp <YOUR_OTP>`
9. `rm rails_hmvc-*.gem`
10. Push tags + commits (use temp-remote if `.cursor/remote` exists, otherwise `git push origin main --tags`)
11. `gh release create vX.Y.Z --title "vX.Y.Z" --generate-notes`

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
