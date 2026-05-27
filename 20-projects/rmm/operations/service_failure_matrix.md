---
title: service_failure_matrix
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [operations, risk, failure-modes]
supersedes: ""
related: ["[[catastrophic_scenarios]]", "[[data_level_incidents]]", "[[risk_assessment]]"]
---

| Service | Impact | Response | Recovery |
|---------|--------|----------|----------|
| Vercel | Platform down | Wait (99.99% SLA) | Minutes to hours |
| Strava API | No new sync | Activities queue. Webhooks resume on recovery. | Hours |
| Garmin API | No Garmin sync | Same — queue and resume | Hours |
| Google Maps Elevation API | GPS altitude fallback | Process with flag. Re-process on recovery. | Hours |
| PostgreSQL database | Partial function | Alert V immediately. Automated recovery. | Minutes to hours |
| Claude (AI) | No content, architecture, code | Manual work continues. Tasks queue. | Hours |
| Claude Code | No implementation | Architecture continues in Claude.ai. | Hours |
| Resend (email) | No transactional emails | Queue and send on recovery. | Hours |
| GitHub | No deploys, no version control | Stop writing code until recovery. | Rare |
