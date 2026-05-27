---
title: workforce_model
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [operations, workforce, ai]
supersedes: ""
related: ["[[ai_resource_management]]", "[[automation_architecture]]", "[[partnership_and_growth_strategy]]"]
---

### Who Does What

**V (Human):** Strategic decisions, creative direction, community relationships, quality review, partnership conversations, event presence, final approval on anything public-facing.

**Claude (AI):** Architecture and system design, code generation (Claude Code), content drafting, formula development, business strategy, data analysis, document production.

**Automation (Scripts, Cron Jobs, Webhooks):** GPX processing, activity ingestion, anti-gaming flags, RPS recalculation, email delivery, database backups, uptime monitoring, score decay.

**Third-Party Services:** Vercel, Strava/Garmin, Google Maps/Mapbox, Resend/Postmark, Stripe, GitHub, Cloudflare.

### The Decision Framework

Step 1: Can a script handle this? (Deterministic = automation.)
Step 2: Does it require intelligence but not V's judgment? (Claude.)
Step 3: Does it require V's judgment, relationships, or presence? (V does it personally.)

### Claude Operating Model

**Role 1 — Architect (Claude.ai + Projects).** System design, formula development, strategy.
**Role 2 — Engineer (Claude Code).** Implementation from instruction documents.
**Role 3 — Writer (Claude.ai).** Content — routes, social, emails, docs.
**Role 4 — Analyst (Claude.ai).** Data analysis, calibration, reports.

### Function-to-Resource Assignment

| Function | Primary | Secondary | Notes |
|----------|---------|-----------|-------|
| Platform development | Claude Code | Claude.ai (architecture) | Instruction doc → Claude Code |
| Formula engine | Claude.ai (design) | Claude Code (implementation) | Formula project only |
| API integrations | Claude Code | V (API key setup) | OAuth requires manual app registration |
| Bug fixing | Claude Code | V (triage) | V identifies, Claude Code fixes |
| Performance monitoring | Automation | V (weekly review) | Alerts on failure only |
| Database management | Automation | V (monthly review) | Backups automated |
| Route descriptions | Claude.ai (draft) | V (review + voice) | Template-based |
| Social media | V (post) | Claude.ai (draft) | V's voice, V's photos |
| Email communications | Automation (delivery) | Claude.ai (draft) | Templates built once |
| Community management | V | — | Not delegatable |
| Photography | V | — | Authentic Peninsula content |
| Event creation | V (decide) | Claude.ai (announcements) | Strategic + content |
| Event operations | V + Automation | — | V present, system validates |
| Leaderboard management | Automation | V (dispute review) | Auto-processed |
| Route library curation | Automation (grading) | V (review + describe) | Pure GPS grading is automatic |
| Financial tracking | V | — | Monthly, 30 minutes |
| POPIA compliance | Claude.ai (draft) | V (review + publish) | One-time then maintain |
| IP protection | V | — | Authorship record, trademark |
| Athlete onboarding | Automation | V (support if stuck) | Fully automated flow |
| Partnership outreach | V | Claude.ai (draft proposals) | Relationships are personal |
| Athlete support | V | Claude.ai (FAQ responses) | V triages and responds |
