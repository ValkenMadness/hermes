---
title: development_workflow
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-12
updated_by: claude_cowork
tags: [operations, workflow, development]
supersedes: ""
related: ["[[claude_project_structure]]", "[[ai_resource_management]]", "[[asset_pipeline]]", "[[operating_philosophy]]"]
---

The proven pattern:
1. V identifies feature need or bug.
2. Claude.ai conversation produces architecture and requirements.
3. Claude produces an instruction document — complete, self-contained specification.
4. Claude Code implements against the codebase.
5. V reviews (git diff, manual testing, Formula Lab verification).
6. V deploys via Vercel (git push to main).

### Deployment Process

**Standard (updated 2026-05-12):** git push to main → Vercel auto-deploys to production immediately. All experimental features are behind admin gating, so direct-to-main deploys are safe. No preview step needed for admin-gated pages.

**Risky deployments:** Feature branch → Vercel preview → thorough testing → merge to main. Only needed for changes to public-facing pages (Map, About, legal pages).

**Rollback:** Vercel supports instant rollback to any previous deployment.

**Environment variables:** All formula values, API keys, and secrets in Vercel env vars. .env.example lists required variable names without values.

### Testing & QA

No QA team. V is the sole tester. Before every deployment: UI changes checked on preview URL. Formula changes tested against Formula Lab. API changes tested with Strava test endpoint.

Automated safeguards: linting and type checking on push (GitHub Actions). Basic integration tests for GPS pipeline.
