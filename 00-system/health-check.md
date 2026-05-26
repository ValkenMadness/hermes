---
title: health-check
domain: system
type: knowledge
status: active
created: 2026-05-26
updated: 2026-05-26
updated_by: claude
tags: [system, maintenance, health-check]
supersedes: ""
related: ["[[metadata-schema]]", "[[domain-map]]", "[[decision-log]]"]
---

# Hermes System Health Check

Review monthly or whenever the system feels like it might be drifting. This merges the existing vault's brain health checklist (proven effective) with Hermes governance additions.

Last reviewed: _not yet reviewed_
Reviewed by: _pending first review_

---

## Structural Health

- [ ] Every `.md` file has exactly one frontmatter block, properly opened and closed with `---`
- [ ] Every `title` field matches its filename (without .md extension)
- [ ] Every `related` field uses proper YAML array syntax: `["[[link_one]]", "[[link_two]]"]`
- [ ] No file references itself in its own `related` field
- [ ] No duplicate tags in any file
- [ ] Every wiki link in every `related` field points to a file that actually exists
- [ ] No files sitting at unexpected locations (everything in its domain folder or `00-system/`)
- [ ] No spaces, ampersands, or special characters in any filename
- [ ] All tags use hyphens, not underscores or ampersands
- [ ] No orphaned files (every file is linked to by at least one other file)
- [ ] All domains have current INDEX.md files
- [ ] Folder structure matches domain map
- [ ] No unexpected new directories

## Metadata Health

- [ ] Required frontmatter present on all notes (spot-check 10 random)
- [ ] No frontmatter drift (fields consistent with `metadata-schema.md`)
- [ ] Status fields current — no `status: active` documents containing stale information
- [ ] `updated` dates are recent where content has changed
- [ ] `updated_by` fields reflect actual last editors

## Content Health

- [ ] No documents under 25 words (excluding INDEX files and READMEs)
- [ ] No documents over 3,000 words unless justified (e.g., master task list)
- [ ] All codebase documents match the current state of repos
- [ ] All decision documents are still accurate
- [ ] Open questions have been reviewed — resolved ones marked complete
- [ ] No knowledge trapped in chat logs that should be in Hermes

## Governance Health

- [ ] Decision log up to date with recent decisions
- [ ] Agent manifests reflect current usage patterns
- [ ] Recent session summaries exist in `90-logs/sessions/`
- [ ] Git history is clean and follows commit message format
- [ ] Handoff briefs in `40-operations/handoffs/` are either active or marked complete

## Process Health

- [ ] Every recent build session produced a completion report
- [ ] Completion reports were processed into Hermes updates
- [ ] The `40-operations/inbox/` is empty or contains only recent captures

## Operational Health

- [ ] Opening Obsidian provides immediate operational clarity
- [ ] Retrieval feels fast and accurate
- [ ] No AI-generated garbage accumulating
- [ ] System feels intentional, not bureaucratic

## The Critical Question

**Is Hermes currently reducing operational friction, or becoming operational friction?**

If creating a note feels like administrative labor, the schema is too heavy. If finding information takes longer than it should, the indexes need work. If the system feels sterile or over-mechanical, something has gone wrong.

## Failure Mode Scan

- [ ] No metadata drift
- [ ] No abandoned indexes
- [ ] No stale manifests
- [ ] No folder sprawl
- [ ] No "tool collecting" (automation for automation's sake)
- [ ] No hidden complexity
- [ ] No over-automation
- [ ] No AI hallucination contamination
- [ ] No excessive note splitting (over-atomization)
- [ ] No runaway automation
- [ ] No dependency creep

## Notes

_[Observations, concerns, proposed changes from this review]_
