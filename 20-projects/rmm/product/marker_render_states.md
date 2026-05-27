---
title: marker_render_states
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [product, map, markers]
supersedes: ""
related: ["[[peak_tier_system]]", "[[65_named_peninsula_peaks]]", "[[base_map_visual_design]]", "[[animation_system]]", "[[asset_pipeline]]", "[[map_system_markers_and_interactions]]"]
---

| State | Zoom | What Shows | Which Features | Implementation |
|-------|------|-----------|----------------|---------------|
| T1 — Macro | 8–11* | Minimal icon. Category symbol only. No text. | All peaks. All categories. | Symbol layer |
| T2 — Regional | 11–13* | Icon + abbreviated label. Elevation for peaks. | All peaks. | Symbol layer |
| T3 — Area | 13–15* | Illustrated icon for Tier 1 and 2. Full name label. | Tier 1 and 2 only. | Symbol layer |
| T4 — Detail | Click/tap only | Full bespoke illustration. Complete detail panel. | Summited peaks only. | HTML Marker |
| T5 — Deep Zoom | 18+ | Snaps back to small generic T1 icon. | All peaks. | Symbol layer |

*Zoom thresholds provisional — set by visual testing and locked. T4 NEVER appears automatically — interaction-triggered only.
