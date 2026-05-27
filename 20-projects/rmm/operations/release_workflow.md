---
title: release_workflow
domain: rmm
type: knowledge
status: active
created: 2026-04-25
updated: 2026-05-12
updated_by: claude_cowork
tags: [operations, git, deployment, workflow]
supersedes: ""
related: ["[[website_architecture]]", "[[master_task_list]]"]
---

# Release Workflow

**Updated 2026-05-12:** Preview-first workflow removed. All work pushes directly to `main`. Everything experimental is gated behind admin access (`localStorage.rmm_admin`), so production is safe for direct deploys.

## Branches

- **`main`** = production AND working branch. All daily work happens here. Auto-deploys to runmadmaps.com on every push.
- **Feature branches** (optional) = branch off `main` for large isolated features or risky refactors, merge back to `main` when ready. Use Vercel preview URLs for testing these if needed.

## Daily Workflow

1. Work directly on `main`
2. Commit with clear messages
3. Push to `origin main` — Vercel auto-deploys to production
4. Admin-gated pages (Shop, Intelligence, Leaderboards, Dashboard) are not visible to public users, so deploying in-progress work is safe
5. Non-admin pages (Map, About, Sign In/Up, Profile, legal pages) should be tested locally before pushing

## Rules

- All AI models work on `main` unless explicitly told otherwise
- Admin-gated features can be deployed incomplete — the public never sees them
- Public-facing pages should be verified before pushing
- Vercel supports instant rollback to any previous deployment if something breaks
- The CLAUDE.md in the repo should be updated to reflect `main` as the working branch
