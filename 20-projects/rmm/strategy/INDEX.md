---
title: RMM Strategy Index
domain: rmm
type: index
status: active
created: 2026-05-26
updated: 2026-05-26
updated_by: claude-cowork
tags: [index, strategy, rmm]
supersedes: ""
related: ["[[phased_build_plan]]", "[[launch_readiness_checklist]]"]
---

# RMM Strategy

Strategic planning, market analysis, competitive positioning, revenue modelling, and build roadmap for the Run Mad Maps platform. This sub-domain covers the "why" and "when" — decisions about "how" live in `rmm/decisions/`.

## Contents

### Market Analysis

| Note | Description |
|------|-------------|
| [[the_global_trail_running_market]] | Global market size, CAGR, participation trends — the structural tailwind |
| [[the_south_african_trail_running_market]] | SA-specific market data — UTCT, Comrades, event growth, academic validation |
| [[the_cape_peninsula_specifically]] | Why the Peninsula is the right launch geography — UNESCO, peaks, events, clubs |
| [[addressable_market_estimate]] | TAM estimate: 15,000–40,000 across four segments |

### Competitive Positioning

| Note | Description |
|------|-------------|
| [[the_competitive_landscape]] | What Strava/AllTrails/Garmin/Komoot/TrainingPeaks do and don't do — RMM's strategic gap |
| [[the_fitness_tech_layer]] | Market valuations and revenue models of major fitness tech platforms |
| [[revenue_model_comparison]] | Side-by-side revenue stream comparison: Strava vs AllTrails vs RMM |

### Revenue & Risk

| Note | Description |
|------|-------------|
| [[revenue_scenarios]] | Three-year revenue projections across five streams (ZAR) |
| [[risk_assessment]] | Risk matrix and competitive threat analysis |

### Roadmap & Execution

| Note | Description |
|------|-------------|
| [[phased_build_plan]] | Six-phase build plan from Foundation to Growth, V1b–V4 milestones, non-negotiable build sequence |
| [[the_expansion_path]] | Geographic expansion strategy: Peninsula → Partnerships → Game Maker licensing |
| [[launch_readiness_checklist]] | 64-item launch checklist with live status tracking (last updated 2026-05-22) |
| [[trail_ecosystem_build_phases]] | Six-phase Trail Ecosystem implementation plan with handoff protocols (Phases 1–4 complete) |

## Cross-Domain Dependencies

- **Strategy → Decisions**: Strategic direction informs locked decisions; decisions constrain execution
- **Strategy → Product**: `phased_build_plan` and `trail_ecosystem_build_phases` drive the product backlog
- **Strategy → Operations**: `launch_readiness_checklist` tracks operational readiness across all domains
- **Strategy → Finance**: `revenue_scenarios` feeds into `financial_tracking_and_cost_monitoring`
- **Strategy → Legal**: Launch checklist items #21–#32 track legal compliance

## Retrieval Guidance

- For "what is RMM and why does it matter" → start with `the_competitive_landscape` then `the_cape_peninsula_specifically`
- For "where are we in the build" → `launch_readiness_checklist` is the single source of truth
- For "what's the business model" → `revenue_scenarios` + `revenue_model_comparison`
- For "what's the next feature to build" → `trail_ecosystem_build_phases` (active implementation plan)
- For "how big is the market" → follow the chain: global → SA → Peninsula → addressable estimate
