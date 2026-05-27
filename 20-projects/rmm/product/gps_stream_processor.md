---
title: gps_stream_processor
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [product, gps, engine, formula-lab]
supersedes: ""
related: ["[[gps_processing_pipeline]]", "[[route_grading_system_v3]]", "[[runner_performance_score_rps]]", "[[formula_lab_engine_files]]", "[[data_decisions]]", "[[data_integrity_and_anti_gaming]]", "[[formula_development_history]]"]
---

The GPS Stream Processor is the foundation of the entire engine. It runs first on every activity ingest. All other systems consume its outputs.

### Core Principle

Every metric used in any scoring formula must be calculated from first principles using the raw GPS coordinate stream. Platform-reported values (Strava Moving Time, Garmin elevation gain, etc.) are recorded for reference but never used in any scoring formula. Two athletes on the same run must produce identical RMM values regardless of device or platform.

### Core Outputs

- **RMM Moving Time:** Calculated from GPS stream using per-activity-type movement thresholds. Only moving time counts for scoring.
- **DEM-Corrected Elevation Profile:** Each GPS coordinate cross-referenced against a Digital Elevation Model. Smoothing pass suppresses elevation changes below 2m between consecutive points.
- **RMM Average Pace:** Distance ÷ RMM Moving Time, in seconds per kilometre. All pace arithmetic uses seconds — never decimal minutes.
- **RMM Average Speed:** Distance ÷ RMM Moving Time (hours), in km/h.
- **Elevation Density:** Total DEM-corrected elevation gain ÷ distance, in metres per kilometre (m/km).

### Movement Thresholds `[LOCKED]`

| Activity Type | Movement Threshold | Rationale |
|--------------|-------------------|-----------|
| Road Run | 1.5 km/h | Below this is standing, not running |
| Trail Run | 1.0 km/h | Technical terrain legitimately slows to near-walk |
| Hike / Walk | 0.5 km/h | Very slow walking is still walking |

All thresholds live in environment variables. Never in code.

### Derived Terrain Metrics

**Gradient Variability:** Standard deviation of per-100m gradient segments across the route.

**Max Sustained Gradient:** Steepest average gradient over any continuous 500m window. Always ≥ 0 (ascent only). Feeds TBS at 30% weight.

**Climb Count:** Number of distinct ascents. A climb starts when the route gains ≥30m continuously upward and ends when the route descends >10m from the local high point. Both thresholds in env vars.

**Climb Structure Classification:** Each route classified into one of four types (evaluated in order, first match wins):
- **Technical:** ≥4 climbs with average descent between climbs <50% of average climb gain.
- **Single Ascent:** One climb accounts for >70% of total elevation gain, climb count 1–2.
- **Stacked:** >60% of total gain concentrated in one half of the route.
- **Even/Rolling:** No climb exceeds 30% of total gain, max sustained gradient <15%.

**Terrain Brutality Score (TBS):** `[LOCKED]`
> TBS = Elevation Density × 50% + Max Sustained Gradient × 30% + Gradient Variability × 20%

**Route Complexity Score:**
> Route Complexity = Climb Count × 40% + Effort Index × 35% + Split Deviation × 25%

**Effort Index:**
> Effort Index = RMM Moving Time ÷ Expected Time at Flat Pace

### Pace Consistency — Three-Tier System `[LOCKED]`

**Tier 1 — Full Measurement (≥5 complete km splits).** Gradient-normalised CV from the middle 80% of splits (first and last 10% trimmed). Score = 1 − CV.

**Tier 2 — Partial Measurement (2–4 complete km splits).** Gradient-normalised CV from ALL splits, no trimming.

**Tier 3 — Default (<2 complete km splits).** Defaults to 90-day discipline average. Falls back to 0.85 if no average exists. Tier 3 activities CONTRIBUTE to the weighted PC average rather than being excluded.

Tier 2/3 activities validated by F10 (Short Activity Validation).

### Timestamp-Free GPX Support

The GPS processor accepts GPX files without timestamp data. Planned routes and routes from route planners are fully supported. Time-dependent values default to None/0. Route grading works fully.

### Excluded Metrics `[LOCKED]`

- **Cardiac Cost:** Depended on Threshold HR (not available via API). Excluded entirely.
- **Personal Effort Score:** Depended on Cardiac Cost. Excluded entirely.

Both formally excluded in Entry 002 and confirmed in all subsequent sessions.
