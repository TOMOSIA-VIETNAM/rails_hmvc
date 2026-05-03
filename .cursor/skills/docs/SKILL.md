---
name: rails-hmvc-docs
description: Write and maintain multilingual documentation (English, Vietnamese, Japanese) for the Rails HMVC gem. Use when creating, updating, or translating docs files.
---

# Multilingual Documentation

## Directory Structure

```
docs/
├── en/                  # English (primary)
├── vi/                  # Vietnamese
└── ja/                  # Japanese
```

Each language folder has the same set of files:
`getting-started.md`, `architecture.md`, `generators.md`, `components.md`, `testing.md`

## Rules

1. English (`docs/en/`) is the primary source of truth
2. Every file in `en/` MUST have a corresponding file in `vi/` and `ja/` with the same filename
3. When creating or updating a doc, ALWAYS write all three language versions
4. All versions MUST have identical structure: same headings, same sections, same code blocks
5. Only translate prose text — do NOT translate: code blocks, CLI commands, file paths, class names, config keys, technical terms (e.g. "controller", "operation", "form", "serializer")
6. Keep headings in each version's own language

## Workflow

**Creating a new doc:**
1. Write the English version in `docs/en/{name}.md`
2. Translate to `docs/vi/{name}.md`
3. Translate to `docs/ja/{name}.md`
4. Verify all three files have identical structure

**Updating an existing doc:**
1. Edit the English version first
2. Apply the same structural changes to `vi/` and `ja/`
3. Translate any new or changed prose in both languages

## File Purposes

| File | Content |
|------|---------|
| `getting-started.md` | Install, init, first resource — 5 min quickstart |
| `architecture.md` | HMVC concept, request flow diagram, layer roles |
| `generators.md` | All generators, options, config reference |
| `components.md` | How to write each component type (Controller, Operation, Form, Serializer, Error) |
| `testing.md` | Manual testing guide for generators on example app |

## References

- `AGENTS.md` links to `docs/en/` by default
- `dev` skill references `docs/en/` for component patterns
- `README.md` links to all three language versions
