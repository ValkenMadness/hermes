---
title: RMM Product Index
domain: rmm
type: index
status: active
created: 2026-05-27
updated: 2026-05-27
updated_by: claude-cowork
tags: [index, product, rmm]
supersedes: ""
related: ["[[product_vision]]", "[[platform_architecture_and_tech_stack]]"]
---

# RMM Product

Complete product documentation for the Run Mad Maps platform — vision, architecture, formula engines, map system, UX, and the trail ecosystem. This is the largest RMM sub-domain, covering everything that defines what the product is and how it works.

## Contents

### Vision & Architecture

| Note | Description |
|------|-------------|
| [[product_vision]] | Platform vision — the interactive map, the intelligence engine, the SaaS parallel track |
| [[platform_architecture_and_tech_stack]] | Production stack (vanilla JS, Vercel, Supabase, Mapbox), five modules, modular isolation principle, security rules |
| [[platform_pages_and_ux]] | Full website structure (25+ pages), navigation, landing page spec, first-visit experience |
| [[data_architecture]] | GeoJSON vs Supabase split, all table schemas, error states, graceful degradation |

### Formula Engines

| Note | Description |
|------|-------------|
| [[gps_stream_processor]] | Foundation engine — GPS-first metrics, movement thresholds, TBS, pace consistency tiers, excluded metrics |
| [[route_grading_system_v3]] | Pure GPS grading — A–F grades, ED bands, base class matrix, TDS, effort descriptors, validated routes |
| [[runner_performance_score_rps]] | RPS — 5-component weighted score, TDS-adjusted SE, gradient-normalised PC, decay, layers, athlete levels |
| [[race_readiness_engine]] | Five-check readiness assessment — distance, volume, PI, recency, elevation. Secrecy enforcement |
| [[data_integrity_and_anti_gaming]] | Ten validation flags (F1–F10) — GPS mismatch, fabrication detection, yo-yo, short activity |
| [[formula_development_history]] | Eight formula sessions (26–29 March 2026) — from V1 through V3 lock |

### Map System

| Note | Description |
|------|-------------|
| [[base_map_visual_design]] | Dark base, 3D terrain, hillshade, fog, route colouring, label treatment, UI controls |
| [[map_build_sequence]] | Seven build stages + eight pre-build gates |
| [[map_intro_animation]] | Six-step cinematic intro sequence with athlete-aware camera |
| [[marker_render_states]] | T1–T5 zoom states for all map features |
| [[peak_tier_system]] | Three peak tiers — Bespoke (4 peaks), Template, Marker |
| [[65_named_peninsula_peaks]] | Peak count and GeoJSON confirmation status |
| [[animation_system]] | Six marker animation states — static, loop, hover, seasonal, event-live, conditional |
| [[fire_and_safety_zones]] | Five fire zone statuses with visual treatments |
| [[asset_pipeline]] | Naming convention, directory structure, icon pipeline |

### Trail Ecosystem

| Note | Description |
|------|-------------|
| [[trail_ecosystem_design]] | Master design document — 17 sections covering all five trail systems, DB schema, API endpoints, descent grading, implementation status |
| [[trail_ecosystem_build_phases]] | Six-phase implementation plan with handoff protocols (Phases 1–4 complete, 5–6 complete) |

## Cross-Domain Dependencies

- **Product → Decisions**: All `[LOCKED]` tags in product docs reference decisions in `rmm/decisions/`
- **Product → Strategy**: `phased_build_plan` and `launch_readiness_checklist` drive the product roadmap
- **Product → Operations**: `master_task_list` tracks all product work items
- **Product → Codebase**: `website_architecture` maps product specs to actual code files
- **GPS Processor → Route Grading → RPS → Race Readiness**: The four engines form a dependency chain

## Retrieval Guidance

- For "what is RMM" → `product_vision` then `platform_pages_and_ux`
- For "how does scoring work" → start with `gps_stream_processor`, then the specific engine
- For "how is the map built" → `base_map_visual_design` → `map_build_sequence` → `marker_render_states`
- For "how do trails get on the map" → `trail_ecosystem_design` (the master doc)
- For "what's the tech stack" → `platform_architecture_and_tech_stack`
- For formula history and evolution → `formula_development_history`
- All formula parameters are in environment variables — never look for hardcoded values in product docs
