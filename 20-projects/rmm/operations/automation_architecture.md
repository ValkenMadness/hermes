---
title: automation_architecture
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [operations, automation, architecture]
supersedes: ""
related: ["[[ai_resource_management]]", "[[knowledge_continuity]]", "[[workforce_model]]"]
---

### What Gets Automated

| Automation | Trigger | Failure Response |
|-----------|---------|-----------------|
| Activity ingestion | Strava/Garmin webhook | Queue and retry; alert V after 3 failures |
| RPS recalculation | New activity processed | Log error, serve cached scores, alert V |
| Database backup | Daily at 03:00 SAST | Alert V immediately |
| Uptime monitoring | Every 5 minutes | Alert V after 2 consecutive failures |
| SSL certificate | Auto-renew (Vercel) | Alert V 14 days before expiry |
| Email delivery | Platform events | Queue and retry; alert V after 3 failures |
| Strava deauthorisation | Athlete revokes access | Mark disconnected, stop syncing |
| Score decay | Daily at 05:00 SAST | Log error, serve yesterday's scores |

### What Does NOT Get Automated

Social media posting, community responses, partnership outreach, route descriptions, event planning, formula changes, content approval. All require V's judgment, voice, or relationships.

### The Automation Stack

**Vercel Cron Jobs:** Scheduled tasks (daily score recalculation, database maintenance). **Strava/Garmin Webhooks:** Event-driven activity processing as Vercel serverless functions. **GitHub Actions:** CI/CD, automated tests on PR, deployment. **Email automation:** Resend for triggered emails.
