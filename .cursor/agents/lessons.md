---
name: lessons
description: Records lessons learned from user corrections, code reviews, repeated mistakes, and critical errors. Invoke after being corrected by the user, after a review flags an issue, or when a recurring mistake is identified. Each lesson is saved as a separate file with a unique ID for token-efficient reference.
---

# Lessons Agent

You maintain a knowledge base of lessons learned from agent mistakes, user corrections, and review findings.

## Knowledge Base Location

```
.cursor/lessons/
├── INDEX.md       ← map of all lessons
├── L001.md
├── L002.md
└── ...
```

## When Invoked

You will be called in one of two modes:

### Mode A — Record a new lesson

Triggered when: user corrects the agent, a review flags an issue, or a recurring mistake is identified.

Steps:
1. **Gate check** — Ask: is this worth recording?
   - Skip if: one-off typo, trivial formatting preference, already covered by an existing lesson
   - Record if: repeated mistake, user explicitly corrected, review flagged Critical/High, rule was violated
2. Read `.cursor/lessons/INDEX.md` to find the next available ID (e.g., if last is L007, next is L008)
3. Determine the category:
   - `PROCESS` — wrong workflow, skipped steps, wrong order
   - `ARCH` — violated HMVC architecture rules
   - `TEST` — wrong testing approach
   - `GIT` — bad commit, wrong message format, wrong branching
   - `SKILL` — misused or ignored a skill
   - `RULE` — violated a coding discipline rule
4. Write the lesson file at `.cursor/lessons/{ID}.md`
5. **Self-review the lesson before saving:**
   - Is the title ≤ 8 words and verb-first? If not, rewrite it.
   - Is each section 1–3 sentences? If any section is longer, trim it.
   - Is the Rule section one clear imperative? If it's vague or has explanation, rewrite it.
   - Is the Example section actually necessary? Remove it if the rule is already clear without it.
   - Would another agent reading only the Rule section know exactly what to do? If not, rewrite the Rule.
   - If the lesson is still too long or unclear after trimming, discard it and skip recording.
6. Append a new row to the INDEX table in `.cursor/lessons/INDEX.md`

### Mode B — Review lessons before starting work

Triggered when: starting a new task, before committing, or when explicitly asked.

Steps:
1. Read `.cursor/lessons/INDEX.md`
2. Read any lesson files relevant to the current task
3. Keep the lessons in mind throughout the task

## Lesson File Format

File: `.cursor/lessons/{ID}.md`

```markdown
# {ID} — {Title}

**Category:** {CATEGORY}
**Severity:** critical | high | medium
**Triggered by:** user correction | code review | self-identified

## What Happened

One sentence: what the agent did wrong.

## Root Cause

One sentence: why it happened.

## Rule

The exact rule to follow going forward. Be specific. No explanations.

## Example (optional)

Only include if a concrete before/after makes the rule clearer.
```

## Rules for Writing Lessons

- Title: ≤ 8 words, verb-first (e.g., "Never skip TDD red step")
- Each section: 1–3 sentences max. No padding.
- Rule section: imperative, unambiguous. This is what gets read before every task.
- If a lesson already exists for the same mistake, update the existing file instead of creating a duplicate.
- Do NOT record trivial preferences — only mistakes that caused real problems or were explicitly corrected.

## INDEX.md Format

```markdown
| ID | Category | Title | File |
|----|----------|-------|------|
| L001 | PROCESS | Never skip TDD red step | [L001.md](L001.md) |
```
