---
title: brain_health_checklist
domain: system
type: knowledge
status: active
created: 2026-04-24
updated: 2026-04-24
updated_by: claude
tags: [system, maintenance, health-check]
supersedes: ""
related: ["[[master_instruction_deck]]", "[[brain_update_protocol]]"]
---

# Brain Health Checklist

Periodic checks to ensure the vault is healthy, current, and reliable. Run this checklist monthly or whenever the brain feels like it might be drifting from reality.

## Structural Health

- [ ] Every .md file has exactly one frontmatter block, properly opened and closed with `---`
- [ ] Every `title` field matches its filename (without .md extension)
- [ ] Every `related` field uses proper YAML array syntax: `["[[link_one]]", "[[link_two]]"]`
- [ ] No file references itself in its own `related` field
- [ ] No duplicate tags in any file
- [ ] Every wiki link in every `related` field points to a file that actually exists
- [ ] No files sitting at the vault root (everything is in a domain folder or `_system/`)
- [ ] No spaces, ampersands, or special characters in any filename
- [ ] All tags use hyphens, not underscores or ampersands
- [ ] No orphaned files (every file is linked to by at least one other file)
- [ ] Bidirectional links are maintained (if A links to B, B links to A)

## Content Health

- [ ] No documents under 25 words (excluding index files like `locked_decisions_register`)
- [ ] No documents over 3,000 words (split if necessary)
- [ ] All `status: active` documents reflect current reality
- [ ] No `status: active` documents contain stale or outdated information
- [ ] All codebase documents in `rmm/codebase/` match the current state of the repos
- [ ] All decision documents in `rmm/decisions/` are still accurate
- [ ] Open questions in `rmm/open_questions/` are reviewed — any resolved ones should be marked complete

## Process Health

- [ ] Every recent build session produced a completion report
- [ ] Every completion report was processed into brain updates
- [ ] No knowledge is trapped in chat logs that should be in the brain
- [ ] Handoff briefs in `_work/_handoffs/` have been marked complete or are genuinely in progress
- [ ] The `_work/_inbox/` is empty or contains only recent captures awaiting processing

## Coverage Gaps

- [ ] Every major system in the RMM platform has a codebase document
- [ ] Every locked decision has a document in `rmm/decisions/`
- [ ] Every open question has an entry in `rmm/open_questions/`
- [ ] Brand assets (colour palette, typography, voice) are documented
- [ ] Deployment and environment setup is documented
- [ ] Key files lookup table is comprehensive for common edit types

## How to Fix Issues

If structural issues are found: fix them directly. Update frontmatter, repair links, rename files.

If content staleness is found: flag the document for update. Create a task in `_work/_tasks/` or note it for the next relevant conversation.

If process gaps are found: go back through recent chat logs and extract what's missing. Process it through the Brain Manager GPT.

If coverage gaps are found: schedule a session to produce the missing documentation. For codebase gaps, use Claude Code to scan the relevant part of the repo. For business gaps, discuss with ChatGPT and produce the document.
