---
title: map_build_sequence
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [product, map, build-sequence]
supersedes: ""
related: ["[[base_map_visual_design]]", "[[map_intro_animation]]", "[[map_system_overview]]", "[[platform_pages_and_ux]]"]
---

### Pre-Build Gates

| Gate | Requirement | Status | Blocks |
|------|------------|--------|--------|
| G1 | Mapbox Studio custom base style | NOT STARTED | Stage 1 |
| G2 | All GeoJSON files reviewed and confirmed clean | IN PROGRESS | Stage 2 |
| G3 | GPS coordinates confirmed for all 65 peaks | BLOCKER (45/65 imprecise) | Stage 3+ |
| G4 | Supabase project created — all tables built | NOT STARTED | Stage 3 |
| G5 | features table populated | NOT STARTED (needs G4) | Stage 3 |
| G6 | Asset directory structure created | NOT STARTED | Stage 2 |
| G7 | CLAUDE.md created with architecture rules | OVERDUE | Stage 1 |
| G8 | Admin Interface Spec document produced | NOT STARTED | Stage 7 only |

### The Seven Stages

**Stage 1 — Foundation.** GL JS with custom style, 3D terrain, hillshade, fog, camera pitch, style_config from Supabase, full-page and panel contexts, mobile responsive.

**Stage 2 — Static Data Layers.** All GeoJSON sources loaded. Route lines with grade colours and line-z-offset. Peak markers T1. Region boundaries. POI markers. Zone polygons. Zoom thresholds determined.

**Stage 3 — Expression-Driven Styling.** Full T1–T3 zoom expressions. Tier-driven icon switching. Route grade colouring from features table. Fire zone status. Animation state reading. Subscription gates.

**Stage 4 — Interaction, Popups, Intro Animation.** All hover/tap interactions. T4 popups. Event detail panels. Camera flyTo. Platform connections wired.

**Stage 5 — Animation System.** All six states implemented and testable.

**Stage 6 — Overlay Illustrations.** GPS-pinned illustrations with zoom thresholds.

**Stage 7 — Admin Interface.** All admin tools. Separate deployment. Requires G8.
