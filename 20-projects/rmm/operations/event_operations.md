---
title: event_operations
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [operations, events, playbook]
supersedes: ""
related: ["[[content_and_community]]", "[[partnership_and_growth_strategy]]", "[[revenue_streams]]"]
---

### Event Types (in order of complexity)

**Time Trial:** Single route, self-timed within a window. Athletes use own GPS device. Results validated against GPS stream. Low operational cost. Launch-day format.

**Group Run:** Organised group start. Social, community-building. V present.

**Timed Event:** Full competitive timing, results, leaderboard entry. Higher operational cost. Phase 2 format.

### Operations Workflow

**Pre-event (1–2 weeks):** V selects route → Claude drafts announcement → V publishes → athletes register.

**Day-of:** Athletes run with GPS device → activities sync via webhook → GPS processor validates (correct route, within window, anti-gaming clean).

**Post-event (automated):** Results ranked by RMM Moving Time → published to event page → athletes notified → RPS updated.

### Leaderboard Management

Absolute rule `[LOCKED]`: Leaderboard data from official RMM-timed events only. Training data never enters competitive rankings.

Structure: per-route leaderboards, per-event results, seasonal standings. Same F1–F10 flags plus route GPS corridor validation.
