---
title: rps_decisions
domain: rmm
type: decision
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [decisions, rps, locked]
supersedes: ""
related: ["[[locked_decisions_register]]", "[[runner_performance_score_rps]]"]
---

- Always RPS, never APS
- Weights: 25/30/20/15/10
- Continuous exponential decay, half-life 30 days
- Continuous Consistency Modifier with square-root softening
- TDS-adjusted Speed Efficiency
- Gradient-normalised Pace Consistency with saturation curve
- Three-tier PC system
- Layer 2 removed entirely
- Layer 3: decay-weighted average + cross-discipline bonus, floored at best L1
- 90-day window with continuous decay (no cliff)
- Consistency modifier and decay function stay discipline-specific
