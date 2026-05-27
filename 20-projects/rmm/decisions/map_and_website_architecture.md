---
title: map_and_website_architecture
domain: rmm
type: decision
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [decisions, architecture, locked]
supersedes: ""
related: ["[[locked_decisions_register]]", "[[platform_architecture_and_tech_stack]]", "[[website_architecture]]"]
---

- T1–T5 icon state system
- Peak tiers in Supabase, not GeoJSON. Admin-assignable.
- Map style overrides via style_config table
- Intro animation toggle in athletes table
- Admin at admin.run-mad-maps.com. Separate deployment and auth.
- Grade system A–F (not A–D)
- Graceful degradation: all 65 peaks visible at T1/T2 from day one
- Interpolate expressions for line width. Never fixed.
- GeoJSON = geographic truth. Supabase = operational truth.
- Camera pitch and zoom thresholds set by visual testing, locked once set
- Modular isolation: map never imports from another module
- Rebuild: Mapbox style, GL JS layers, hardcoded styling, tilesets, manual markers — all DELETE and rebuild
