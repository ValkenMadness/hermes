---
title: data_decisions
domain: rmm
type: decision
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [decisions, data, locked]
supersedes: ""
related: ["[[locked_decisions_register]]", "[[data_architecture]]", "[[gps_stream_processor]]"]
---

- RMM Moving Time is authoritative (not platform-reported)
- RMM calculates own Moving Time from GPS stream
- DEM-corrected elevation (not raw GPS altitude, not platform-reported)
- RMM recalculates Average Pace and Speed from its own Moving Time
- Cadence excluded — unreliable cross-device
- Heart rate excluded — Threshold HR not available via API
- Max Speed excluded — too narrow and noisy
- Cardiac Cost and Personal Effort Score excluded entirely
