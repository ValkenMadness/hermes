---
title: route_grading_system_v3
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [product, formula, route-grading, formula-lab]
supersedes: ""
related: ["[[route_grading_decisions]]", "[[runner_performance_score_rps]]", "[[gps_stream_processor]]", "[[formula_development_history]]", "[[formula_lab_engine_files]]", "[[race_readiness_engine]]"]
---

Every route receives a Difficulty Class, a Terrain Difficulty Score, and an Effort Descriptor. The grade is objective — it describes the route, not the athlete.

### The Pure GPS Principle `[LOCKED]`

The Route Grading System must grade from GPS data alone. No manual curator tags. No athlete performance data. No subjective input. Upload a GPX file, get a grade. Same file = same grade. Always.

This principle was established in Entry 007 after discovering that V2's dependence on manual curator tags caused Platteklip Gorge (TBS 98.2) to grade B while Lion's Head (TBS 63.4) graded A.

### Six-Grade System (A through F) `[LOCKED]`

| Grade | Name | Description |
|-------|------|-------------|
| A | Extreme | Gorge-class. Relentless sustained brutality. |
| B | Performance | Serious mountain terrain. Tests strong athletes. |
| C | Mountain | Real climbing. Demands fitness and preparation. |
| D | Conditioning | Moderate hills. Honest sustained effort. |
| E | Accessible | Rolling to flat. Buildable. Entry point. |
| F | Recovery | Flat, short. Active recovery. |

A = hardest. Intentional inversion — A-grade athletes, A-races, A-game.

### Six Elevation Density Bands `[LOCKED]`

| Band | Range (m/km) | Character |
|------|-------------|-----------|
| Low | < 10 | Flat to gently rolling |
| Rolling | 10–20 | Noticeable hills |
| Hilly | 20–35 | Significant elevation |
| Steep | 35–60 | Demanding terrain |
| Mountain | 60–100 | Serious mountain routes |
| Extreme | 100+ | Gorge-class density |

### Base Class Matrix `[LOCKED]`

Primary class determined by Distance Band × Elevation Density Band:

| ED \ Distance | Short (<15km) | Medium (15–40km) | Long (40–80km) | Ultra (80km+) |
|--------------|--------------|-----------------|----------------|--------------|
| Low (<10) | F | E | D | D |
| Rolling (10–20) | E | D | D | C |
| Hilly (20–35) | D | C | C | B |
| Steep (35–60) | C | B | B | A |
| Mountain (60–100) | B | A | A | A |
| Extreme (100+) | A | A | A | A |

### GPS-Derived Modifier System `[LOCKED]`

Two independent modifier paths. Take the HIGHER of the two (not additive). Cap at +2, cap at A.

**Path 1 — Terrain Brutality Score:** TBS ≥ 80 → +1 class. TBS ≥ 95 → +2 classes.

**Path 2 — Total Elevation Gain (with distance qualifier):** Gain ≥ 600m AND Distance ≥ 15 km → +1 class. Gain ≥ 1200m AND Distance ≥ 25 km → +2 classes.

Distance qualifier prevents short gorge routes from double-dipping.

### Terrain Difficulty Score (TDS) — 1 to 10 `[LOCKED]`

Numeric score for granular difficulty discrimination within letter grades.

> Base TDS = round(TBS / 10), clamped 1–10

Long-route gain floors: Gain ≥ 600m + Distance ≥ 15 km → TDS floor 5. Gain ≥ 1200m + Distance ≥ 25 km → TDS floor 7.

This solves the "both are A but one will destroy you" problem. Lion's Head = A · 6/10. Platteklip = A · 10/10.

### Effort Descriptor System `[LOCKED]`

GPS-derived text labels communicating route effort character: Flat, Undulating, Hilly, Steady Rise, Sustained Climb, Big Push, Relentless Ascent, Relentless Terrain, Front-Loaded. All thresholds in env vars.

### Route Type Tags `[LOCKED]`

Tags define physiological purpose, not difficulty. Technical tag removed in V3. Remaining tags: Recovery · Aerobic · Tempo · Strength · Endurance · Mental Grind · Benchmark (manual-only exception).

### Grade Display Format `[LOCKED]`

> Class [A-F] · [TDS]/10 — [Effort Descriptor] · [Distance] · [Gain] · [ED] m/km

Example: "Class A · 10/10 — Relentless Ascent · 4.2 km · 888m gain · 212 m/km"

### Validated Peninsula Routes

| Route | Distance | Gain | ED (m/km) | TBS | Grade |
|-------|----------|------|-----------|-----|-------|
| Promenade Stretch | 2.65 km | 6m | 2.4 | 2.5 | F · 1/10 — Flat |
| Silvermine | 3.60 km | 155m | 43.1 | 26.2 | D · 3/10 — Strength |
| Ou Wapad | 4.78 km | 310m | 64.8 | 35.0 | C · 4/10 — Strength |
| Elsie's Peak | 1.65 km | 199m | 121.0 | 59.6 | A · 6/10 — Strength |
| Lion's Head | 2.12 km | 278m | 131.1 | 63.4 | A · 6/10 — Strength |
| Skeleton Gorge | 2.21 km | 620m | 281.0 | 98.6 | A · 10/10 — Strength |
| Platteklip Gorge | 4.20 km | 888m | 211.7 | 98.2 | A · 10/10 — Strength |

All 7 grades confirmed defensible by V.
