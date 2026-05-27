---
title: race_readiness_engine
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [product, formula, race-readiness, formula-lab]
supersedes: ""
related: ["[[race_readiness_decisions]]", "[[runner_performance_score_rps]]", "[[route_grading_system_v3]]", "[[formula_development_history]]", "[[formula_lab_engine_files]]"]
---

Assesses whether a specific athlete is prepared for a specific route based on their 90-day training history.

### Five-Check System

| Verdict | Condition | Meaning |
|---------|-----------|---------|
| READY | 5 of 5 pass | Go. The training supports this challenge. |
| CLOSE | 4 of 5 pass | Almost. One specific gap to address. |
| NOT YET | <4 pass | More preparation needed. Gaps identified. |

### The Five Checks

**Check 1 — Distance Coverage.** Single activity ≥ X% of target route distance within 90-day window. Coverage percentage varies by distance band (env vars).

**Check 2 — Volume Load.** 90-day total distance ≥ route distance × multiplier. Multiplier decreases at ultra distances.

**Check 3 — Performance Index.** PI ≥ threshold on at least one activity with base class ≥ target route's class.
> PI = (Expected Time for Grade × Distance) ÷ Actual RMM Moving Time

No HR component. Permanently removed in Entry 002.

**Check 4 — Recency.** Minimum 3 activities of matching type in the last 21 days.

**Check 5 — Elevation Coverage.** 90-day elevation ≥ route elevation × multiplier. Auto-passes if route elevation < 50m.

### Secrecy Enforcement `[LOCKED]`

API responses show computed targets ("you need 57 km") but NEVER expose formula parameters. Export reports strip the all_activities_with_pi array. No formula parameters in any output.
