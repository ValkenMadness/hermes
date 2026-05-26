---
title: open_questions_master_list
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [open-questions, register, unresolved]
supersedes: ""
related: ["[[locked_decisions_register]]", "[[launch_readiness_checklist]]", "[[phased_build_plan]]"]
---

## High Priority `[OPEN]`

| ID | System | Question |
|----|--------|----------|
| RPS-11 | RPS | PC gradient model calibration — starting values need validation |
| RPS-12 | RPS | TDS_BONUS_RATE calibration — needs validation with real data |
| RPS-13 | RPS | Descent pace modelling — verify on runnable vs technical descents |
| ST3-1 | All | Real athlete data calibration — source real Peninsula GPX exports |
| ST3-3 | Race Readiness | PI thresholds and expected time baselines need real data validation |

## Medium Priority `[OPEN]`

| ID | System | Question |
|----|--------|----------|
| RPS-5 | RPS | Level band boundary validation against real athlete population |
| RPS-7 | RPS | Benchmark ceiling review cadence post-launch (quarterly proposed) |
| RG-7 | Route Grading | Effort Descriptor coverage — missing descriptors for some route types |
| RG-8 | Route Grading | Route Type Tag overlap — 5 of 7 test routes get Strength |
| RG-9 | Route Grading | TDS formula sensitivity at TBS ceiling |
| ST3-2 | Route Grading | Existing routes need re-curation with V3 |
| ST3-4 | Race Readiness | Distance coverage % and volume multiplier validation |

## Lower Priority `[OPEN]`

| ID | System | Question |
|----|--------|----------|
| GPS-1 | GPS Stream | Climb Count threshold validation |
| GPS-2 | GPS Stream | Expected Time at flat pace baseline per activity type |
| GPS-4 | GPS Stream | TBS component weight validation |
| GPS-5 | GPS Stream | Route Complexity Score component weight validation |
| GPS-6 | GPS Stream | DEM smoothing threshold (2m) validation |
| GPS-7 | GPS Stream | Movement thresholds by activity type validation |
| AG-1 | Anti-Gaming | Validation flag threshold calibration |
| AG-2 | Anti-Gaming | Review workflow design |
| AG-3 | Anti-Gaming | Athlete communication for flagged activities |
| ST3-6 | GPS Stream | OSM-based automatic surface classification (future) |

## Open Considerations (Pre-V2)

- Authentication provider confirmation (Supabase Auth assumed)
- Payment provider confirmation (Stripe assumed, spec needed)
- Analytics implementation (minimum: page views, map interaction, email capture, event conversion)
- SEO strategy (meta tags, OG images, structured data)
- Accessibility baseline (WCAG 2.1 AA for non-map UI)
- Beta user gate implementation (invite codes, waitlist, or manual)
- Performance considerations (GeoJSON CDN, Supabase async loading, icon optimisation)
