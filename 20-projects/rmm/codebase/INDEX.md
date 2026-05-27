---
title: RMM Codebase Index
domain: rmm
type: index
status: active
created: 2026-05-27
updated: 2026-05-27
updated_by: claude-cowork
tags: [index, codebase, rmm]
supersedes: ""
related: ["[[website_architecture]]", "[[platform_architecture_and_tech_stack]]", "[[development_workflow]]"]
---

# RMM Codebase

Technical reference documentation for the Run Mad Maps codebase — website architecture, Formula Lab system, map rendering, POI management, styling, deployment, and build status tracking. These notes map product specs to actual code files and track implementation state.

## Contents

### Website Architecture & Reference

| Note | Description |
|------|-------------|
| [[website_architecture]] | Master codebase reference (500+ lines) — full tech stack, directory structure, all serverless functions, module contracts, security model. DO NOT SPLIT. |
| [[website_key_files]] | Every file in the repo with path, purpose, and status |
| [[website_component_map]] | Frontend component inventory — HTML pages, JS modules, CSS structure, shared patterns |
| [[website_data_flow]] | Data flow from Strava/Garmin through API endpoints to Supabase and UI rendering |
| [[website_deployment_and_devops]] | Vercel deployment config, environment variables, GitHub Actions, domain setup |

### Website Build Status

| Note | Description |
|------|-------------|
| [[website_build_status_overview]] | Current implementation state of every page and feature — what's live, partial, or not started |
| [[website_build_status_issues]] | Known bugs, technical debt, and tracked issues with severity and status |

### Website Styling

| Note | Description |
|------|-------------|
| [[website_styling_overview]] | CSS architecture — file structure, design tokens, colour system, typography, layout patterns |
| [[website_styling_patterns_and_animations]] | Reusable component patterns, responsive breakpoints, animation system, dark/light themes |

### Formula Lab

| Note | Description |
|------|-------------|
| [[formula_lab_architecture_overview]] | Formula Lab system architecture — standalone testing environment for GPS, grading, RPS, and readiness engines |
| [[formula_lab_engine_files]] | All Python engine files — GPS processor, route grader, RPS engine, race readiness, anti-gaming, descent grader |
| [[formula_lab_config_and_data_layer]] | Configuration management, environment variables, Supabase integration, data schemas |
| [[formula_lab_api_and_frontend]] | API endpoints, React frontend components, GPX upload flow, result rendering |
| [[formula_lab_build_status_overview]] | Formula Lab implementation state — what's working, what's pending |
| [[formula_lab_build_status_issues]] | Formula Lab bugs and technical debt |

### Map System

| Note | Description |
|------|-------------|
| [[map_system_overview]] | Map initialisation, Mapbox GL JS setup, layer management, filter sidebar, module architecture |
| [[map_system_terrain_layers]] | GeoJSON sources, trail/contour/route layers, terrain rendering, tileset references |
| [[map_system_markers_and_interactions]] | Peak markers, POI markers, click/hover interactions, popups, camera controls |

### POI System

| Note | Description |
|------|-------------|
| [[poi_system_reference]] | POI Manager admin tool — 14 categories, CRUD operations, map preview, coordinate handling |

### Security

| Note | Description |
|------|-------------|
| [[security_audit_findings_2026_05_22]] | 2026-05-22 audit — 3 Critical (formula IP in git, .gitignore encoding, OAuth CSRF), 5 High, 2 Medium, 3 Low |

## Cross-Domain Dependencies

- **Codebase → Product**: `website_architecture` implements specs from `product/platform_architecture_and_tech_stack`; Formula Lab engines implement `product/gps_stream_processor`, `product/route_grading_system_v3`, `product/runner_performance_score_rps`, `product/race_readiness_engine`
- **Codebase → Operations**: `website_deployment_and_devops` implements `operations/release_workflow`; `website_build_status_overview` tracks progress against `operations/master_task_list`
- **Codebase → Decisions**: Implementation choices reference locked decisions in `decisions/`
- **Codebase → Strategy**: Build status maps to `strategy/phased_build_plan` milestones

## Retrieval Guidance

- For "what's the tech stack / how is the code structured" → `website_architecture` (the master reference)
- For "what files exist in the repo" → `website_key_files`
- For "what's built vs not built" → `website_build_status_overview`
- For "known bugs or debt" → `website_build_status_issues` + `formula_lab_build_status_issues`
- For "how does the map work in code" → `map_system_overview` → `map_system_terrain_layers` → `map_system_markers_and_interactions`
- For "how do the formula engines work in code" → `formula_lab_architecture_overview` → `formula_lab_engine_files`
- For "how does data flow through the system" → `website_data_flow`
- For "CSS and styling" → `website_styling_overview` → `website_styling_patterns_and_animations`
- For "deployment and DevOps" → `website_deployment_and_devops`
- For "security issues" → `security_audit_findings_2026_05_22`
