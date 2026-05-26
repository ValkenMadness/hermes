---
title: git-governance
domain: system
type: knowledge
status: active
created: 2026-05-26
updated: 2026-05-26
updated_by: claude
tags: [system, git, governance, version-control]
supersedes: ""
related: ["[[handoff-protocol]]", "[[decision-log]]"]
---

# Hermes Git Governance

Git is the memory, history, and recovery layer for Hermes. Every change is tracked, every state is recoverable, every decision is auditable.

---

## Repository Setup

- **Remote**: GitHub private repository (or Gitea if self-hosted)
- **Auth**: SSH or HTTPS — must be working before any migration begins
- **Location**: Hermes root directory (`E:\20 - Project Hermes`)

---

## Branching Strategy

- **`main`** is stable. This is the only branch that matters.
- Migration happens directly on `main`. This is a single-user system — Git history provides full rollback capability. Creating migration branches adds complexity without meaningful safety benefit.
- Optional feature branches for risky structural changes (e.g., schema modifications that affect many notes). Merge back to `main` when confirmed.

---

## Commit Frequency

Commit after every meaningful unit of work:

- A batch of 5-10 migrated notes = one commit
- A schema change = one commit
- A governance document created/updated = one commit
- A session's worth of work = at least one commit

Do NOT wait for end-of-day commits. Frequent small commits are better than infrequent large ones — they make rollback granular and history readable.

---

## Commit Message Format

```
[agent:name] [domain:name] Brief description
```

The agent and domain tags are not optional. They make `git log` immediately useful for understanding who changed what and where.

Examples:
```
[agent:claude] [domain:rmm] Migrated overview subdomain (9 notes)
[agent:human] [domain:system] Updated metadata schema v1.1
[agent:chatgpt] [domain:system] Revised domain map priorities
[agent:claude-cowork] [domain:rmm] Normalized frontmatter for codebase notes
[agent:claude-code] [domain:automation] Added frontmatter validation script
```

---

## .gitignore

```
# Obsidian workspace files (user-specific)
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.trash/

# OS files
*.DS_Store
Thumbs.db
```

**Track other `.obsidian/` config files** — they preserve settings (plugins, themes, hotkeys) that are part of operational state. If Hermes needs to be restored from Git, the Obsidian configuration should restore with it.

---

## What Gets Committed

Everything in the Hermes directory gets committed except what's in `.gitignore`. This includes:

- All notes (`.md` files)
- All governance documents
- All agent manifests
- All session logs and retrospectives
- All INDEX.md files
- All README.md files
- `.obsidian/` config files (except workspace)
- `.gitignore` itself

---

## What Never Gets Committed

- Secrets, tokens, API keys, passwords
- Large binary assets (if needed, use Git LFS or keep external)
- Temporary working files
- Draft notes that haven't reached `status: draft` in frontmatter

---

## Recovery

Git history is the recovery mechanism. If a migration goes wrong:

1. `git log` to find the last good state
2. `git diff` to see what changed
3. `git revert` or `git checkout` to restore

The legacy vault backup is the nuclear option — used only if Git history is somehow corrupted or insufficient.

---

## Initial Commit

The first commit should contain the complete Phase 1 skeleton:

```
[agent:claude] [domain:system] Initialize Hermes skeleton — Phase 1 complete
```

This establishes the baseline from which all migration history is measured.
