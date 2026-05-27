---
title: route_grading_decisions
domain: rmm
type: decision
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [decisions, route-grading, locked]
supersedes: ""
related: ["[[locked_decisions_register]]", "[[route_grading_system_v3]]"]
---

- Pure GPS grading — no manual curator tags
- 6-grade system A–F. A = hardest.
- 6 Elevation Density bands
- TBS-based GPS modifier (thresholds in env vars)
- Total Gain modifier with distance qualifier
- Modifiers take higher of two paths, not additive, cap +2, cap A
- TDS 1–10 from TBS
- Effort Descriptor system
- Technical tag removed. Climbing merged into Strength.
- Upload flow: GPX, auto-grade, display. No modal, no manual input.
