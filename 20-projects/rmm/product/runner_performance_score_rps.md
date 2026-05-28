---
title: runner_performance_score_rps
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-27
updated_by: claude_cowork
tags: [product, formula, rps, formula-lab]
retrieval_priority: high
supersedes: ""
related: ["[[rps_decisions]]", "[[route_grading_system_v3]]", "[[race_readiness_engine]]", "[[formula_development_history]]", "[[formula_lab_engine_files]]", "[[gps_stream_processor]]"]
---

Always called RPS. Never APS. APS is retired.

Window: 90-day rolling with continuous exponential decay (half-life 30 days). Current level = 90-day decayed rolling score. Lifetime peak level stored permanently.

### Component Weights `[LOCKED]`

| Component | Weight | What It Measures |
|-----------|--------|-----------------|
| Distance | 25% | Total km in 90-day window, decay-weighted |
| Speed Efficiency | 30% | Distance ÷ RMM Moving Time (km/h) — TDS-adjusted |
| Elevation | 20% | Total DEM-corrected elevation gain, decay-weighted |
| Pace Consistency | 15% | 1 − CV of km splits — gradient-normalised |
| Frequency | 10% | Total activity count, decay-weighted |

Weights locked at 25/30/20/15/10 in Entry 002. Confirmed unchanged in Entry 008.

### Speed Efficiency — TDS-Adjusted `[LOCKED]`

> Raw SE = Distance ÷ RMM Moving Time (hours) → km/h
>
> Adjusted SE = Raw SE × (1 + TDS_BONUS_RATE × TDS)

Where TDS is the Terrain Difficulty Score (1–10) and TDS_BONUS_RATE is a single env var (starting value: [value in env vars]). Adjusted SE capped at benchmark ceiling before entering weighted average.

Three options evaluated in Entry 008. Grade buckets (Option A) rejected — step functions violate design philosophy. Elevation rate bonus (Option C) rejected — structural double-counting with Elevation component.

### Pace Consistency — Gradient-Normalised `[LOCKED]`

Instead of measuring raw split consistency, RMM measures split consistency relative to terrain gradient predictions.

For each km split, expected pace is calculated:
> expected_pace = mean_pace × (1 + gradient_adjustment)

The gradient adjustment uses a saturation curve:
> climb_adj = PC_CLIMB_IMPACT × gradient × (1 / (1 + PC_CLIMB_SATURATION × gradient))
> descent_adj = −PC_DESCENT_IMPACT × |gradient| × (1 / (1 + PC_DESCENT_SATURATION × |gradient|))

> Gradient-Normalised PC = 1 − (StdDev(residuals) / mean_pace)

On flat terrain, gradient-normalised PC ≈ raw PC. The fix is invisible where it doesn't need to act.

Env vars: PC_CLIMB_IMPACT, PC_CLIMB_SATURATION, PC_DESCENT_IMPACT, PC_DESCENT_SATURATION. All values in env vars — see Formula Research Document V2.

### Decay Function `[LOCKED]`

> Weight = e^(−λ × days_ago), where λ = ln(2) ÷ 30

Day 0 = 1.000, Day 30 = 0.500, Day 60 = 0.250, Day 90 = 0.125. No cliff edges. Smooth continuous degradation.

### Consistency Modifier `[LOCKED]`

Applied to Distance and Elevation scores only.

> Raw Consistency = Σ(decay weights of actual activities) ÷ Σ(decay weights of expected activities)
> Modifier = min(1.0, Raw Consistency ^ 0.5)

Continuous — no binary threshold. Square root softens: 0.5 consistency → 0.71 modifier.

### Layer Architecture `[LOCKED]`

**Layer 1 — Activity-Exclusive Scores.** Road Run, Trail Run, and Hike/Walk independently scored against own benchmark ceilings. A hiker is not a slow runner.

**Layer 2 — REMOVED.** Entry 005 revealed systematic inflation of +19% to +31%. Removed entirely.

**Layer 3 — Overall RPS.**
> weighted_avg = Σ(L1_rps[d] × decay_sum[d]) / Σ(decay_sum[d])
> If 2+ disciplines active: bonus = weighted_avg × CROSS_DISCIPLINE_BONUS_PCT
> Overall = max(best_L1, weighted_avg + bonus), capped at 100

Cross-discipline bonus default [value in env vars]. Floor guarantee: overall ≥ best L1 score.

### Athlete Levels `[LOCKED]`

| Level | RPS Range | Character |
|-------|-----------|-----------|
| Foundation | 0–20 | Starting out or returning after extended break |
| Active | 21–50 | Consistently training, building base |
| Athlete | 51–70 | Serious training load, demonstrable fitness |
| Competitor | 71–85 | High-level performance, race-ready |
| Elite | 86–100 | Peak Peninsula performance |

Progress within band: Position = (RPS − Band Floor) ÷ (Band Ceiling − Band Floor) × 100.

### Scoring Formula `[LOCKED]`

Step 1: Component Score = (Raw Value ÷ Benchmark Ceiling) × 100, capped at 100.
Step 2: Consistency Modifier applied to Distance and Elevation.
Step 3: Decay weight per activity (exponential, half-life 30 days).
Step 4: Weighted sum — RPS = Σ(Component Score × weight).

All benchmark ceiling values, weights, and parameters in environment variables.
