---
title: RMM Decisions Index
domain: rmm
type: index
status: active
created: 2026-05-26
updated: 2026-05-26
updated_by: claude-cowork
tags: [index, decisions, rmm]
supersedes: ""
related: ["[[locked_decisions_register]]", "[[core_principles]]"]
---

# RMM Decisions

Locked architectural and design decisions for the Run Mad Maps platform. These decisions are **append-only** — they are never deleted, only superseded. All decisions here carry `locked` status and require formal review before modification.

## Contents

| Note | Description |
|------|-------------|
| [[locked_decisions_register]] | Master register of all locked decisions with dates, owners, and status |
| [[core_principles]] | Foundational design and engineering principles governing all RMM development |
| [[data_decisions]] | Data architecture decisions — storage, sync, caching, schema |
| [[formula_lab_decisions]] | Formula Lab architecture — data isolation, export rules, local-only scope |
| [[map_and_website_architecture]] | Map module and website architecture — Mapbox, tilesets, admin, GeoJSON/Supabase split |
| [[race_readiness_decisions]] | Race readiness engine — PI formula, checks, grading, API exposure rules |
| [[route_grading_decisions]] | Route grading system — GPS grading, A–F grades, TBS/TDS, modifiers, upload flow |
| [[rps_decisions]] | Runner Performance Score — weights, decay, consistency modifier, layering, window |

## Cross-Domain Dependencies

- **Route Grading → RPS**: TDS (from route grading) feeds into RPS speed efficiency calculation
- **RPS → Race Readiness**: RPS scores inform race readiness checks
- **Formula Lab → RPS/Route Grading**: Formula Lab houses the development sandbox for both scoring systems
- **Map & Website → Route Grading**: Route grades are displayed on the map module

## Retrieval Guidance

- To understand what has been decided and why, start with `locked_decisions_register`
- For guiding principles behind all decisions, read `core_principles`
- For any specific system's decisions, go directly to the relevant file
- Decisions are **locked** — do not propose changes without referencing the decision and requesting formal review
- New decisions must be appended to `locked_decisions_register` with a new ID
