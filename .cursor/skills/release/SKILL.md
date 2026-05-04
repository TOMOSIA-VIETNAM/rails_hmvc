---
name: rails-hmvc-release
description: Release a new version of the Rails HMVC gem. Handles version bump, CHANGELOG update, git tag, and gem build. Use when the user wants to release, publish, bump version, or tag a new gem version.
---

# Release

## Agent Checklist (follow in order)

When the user says `/release` or asks to release, the agent MUST:

1. **Determine version** — read `lib/rails_hmvc/version.rb` for current version, review unreleased changes (`git log` since last tag), and decide bump level (see Semver below)
2. **Write CHANGELOG** — add a `## [x.y.z] - YYYY-MM-DD` section in `CHANGELOG.md` with entries for this release (see format below)
3. **Commit everything** — working directory must be clean before running the release script
4. **Run Phase 1** — `echo "y" | bin/release <version> --prepare` (test, lint, bump, tag, build)
5. **Tell the user** — after prepare succeeds, tell them to run: `bin/release <version> --deploy`
6. **Stop** — do NOT attempt Phase 2. The deploy step prompts for OTP interactively, which the agent cannot provide.

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

## What `bin/release` Does

### `--prepare` (Phase 1 — agent runs this)

| Step | What it does |
|------|-------------|
| 1/6 | `CI=true bundle exec rspec` — full test suite with coverage enforcement |
| 2/6 | `bundle exec rubocop` — lint check |
| 3/6 | Print all files that will be packaged in the `.gem` |
| 4/6 | Print release notes for the target version from `CHANGELOG.md` |
| — | **Confirmation prompt** — `echo "y"` to auto-confirm |
| 5/6 | Bump `version.rb`, git commit + tag |
| 6/6 | `gem build` — produces `.gem` file, does **not** push |

### `--deploy` (Phase 2 — human runs this)

| Step | What it does |
|------|-------------|
| 1/3 | Prompt for OTP → `gem push` to RubyGems |
| 2/3 | Push commits + tags (auto-detects `.cursor/remote` for temp-remote, otherwise uses `origin`) |
| 3/3 | Create GitHub Release via `gh` CLI with notes from CHANGELOG (auto-detects `--repo` from `.cursor/remote`) |

### Full mode (no OTP required)

```bash
bin/release 1.2.0              # uses GEM_HOST_API_KEY from .env
bin/release 1.2.0 -k work     # uses named key from ~/.gem/credentials
```

## Git Remote: no-remote environments

When `.cursor/remote` exists in the project root, the repo has **no persistent `git remote`** (security policy). The `--deploy` script handles this automatically:

- Reads remote URL from `.cursor/remote` (e.g. `git@github.com:TOMOSIA-VIETNAM/rails_hmvc.git`)
- Adds a temporary remote `_temp_deploy`, pushes, then removes it
- Extracts `owner/repo` from the URL for `gh release create --repo`
- On devices with a normal `git remote origin`, this is ignored — standard `git push` is used

The agent does NOT need to handle git push manually — `--deploy` does it all.

### Yanking a version

```bash
bin/yank 0.1.0              # uses GEM_HOST_API_KEY from .env
bin/yank 0.1.0 -k work     # uses named key from ~/.gem/credentials
```

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
