---
title: formula_lab_build_status_overview
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: claude_code
tags: [codebase, formula-lab, build-status, current-state]
supersedes: ""
related: ["[[formula_lab_build_status_issues]]", "[[formula_lab_architecture_overview]]", "[[formula_lab_engine_files]]", "[[formula_lab_api_and_frontend]]", "[[launch_readiness_checklist]]"]
---

# Formula Lab — Build Status: What's Working

Audit date: 2026-04-23. Based on direct code inspection of all Python and JSX files.

---

## 1. Fully Implemented and Working

### GPS Stream Processor (`gps_processor.py`)
All primary parsing and computation is complete:
- GPX XML parsing with namespace detection
- Haversine distance calculation, cumulative distance per point
- SRTM DEM correction with bilinear interpolation and smoothing fallback
- Moving time calculation per activity type
- Elevation gain/loss/density metrics
- Per-km split extraction with gradient field
- Three-tier pace consistency (CV-based, value-sorted trimming, population std dev)
- Gradient variability and max sustained gradient (sliding window)
- Climb detection state machine and climb structure classification
- Terrain Brutality Score (weighted composite)
- TDS score (TBS → 1–10 with gain floor adjustments)
- Route Complexity Score (weighted composite)
- Coordinate revisit percentage (F9 input)
- HR extraction from GPX extensions
- Elevation profile and coordinate stream generation

### Route Grader V3 (`route_grader.py`)
Complete and confirmed working:
- 6-grade system A–F via BASE_CLASS_MATRIX lookup
- 6-band elevation density classification (Low/Rolling/Hilly/Steep/Mountain/Extreme)
- 4-band distance classification (Short/Medium/Long/Ultra)
- GPS-only modifiers (TBS path + Gain path, takes higher, cap at 2)
- TDS reads from `gps_data["terrain_difficulty_score"]` with fallback computation
- Effort descriptor classification (8 conditions, priority order)
- Route type tag assignment (6 tags)
- Grade display string construction

### RPS Engine (`rps_engine.py`)
Complete:
- Exponential decay with configurable half-life and window
- All five component scores (Distance, Speed Efficiency, Elevation, Pace Consistency, Frequency)
- Gradient-normalised PC (`_compute_gradient_pc`) with quadratic ramp function
- TDS-adjusted Speed Efficiency (`_adjusted_se`) with correct all-weights denominator
- Consistency modifier (applied to Distance + Elevation only)
- Three-layer calculation (L1 per-discipline, L3 overall with cross-discipline bonus, floor at best L1)
- Level band assignment
- Both call sites for `_compute_gradient_pc` (rps_engine.py internal + app.py export) correctly pass `ramp_ceiling` and `ramp_power`

### Race Readiness (`race_readiness.py`)
All five checks implemented and functional:
- Distance Coverage (single-effort requirement by route band)
- Volume Load (90-day total requirement by route band)
- Performance Index (class-matched activities vs expected pace baselines)
- Recency (activity count in last 21 days)
- Elevation Coverage (total gain fraction, auto-pass for flat routes)
- Verdict logic (5=READY, 4=CLOSE, <4=NOT YET)

### Anti-Gaming Validator (`anti_gaming.py`)
Flags F1, F2, F3, F5, F9, F10 are fully implemented. See Section 3 for stubs and gaps.

### Data Layer (`database.py`)
All five tables created. All CRUD operations implemented. Schema migrations run idempotently on startup. Multi-profile support complete.

### API Layer (`app.py`)
All endpoints implemented and responding. Full list in architecture document. Report export endpoint (`/api/report/export`) is complete and comprehensive. Secrecy Rule (no formula values in export) correctly applied.

### Frontend — All Four Views
All views are functional end-to-end:
- `RouteAnalyzer.jsx` — upload, list, detail, map, elevation chart, grade card, inline rename
- `FitnessTracker.jsx` — multi-file upload, RPS display, all-layers view, activity table, profile management
- `RaceReadiness.jsx` — route/profile selection, five check cards, verdict banner
- `CalibrationPanel.jsx` — live formula sliders, debounced RPS preview, report export download

### Config System
All formula values externalised. Missing-key detection at startup (raises `ValueError`). `to_dict()` serialisation for calibration panel. `.env` and `.env.example` are consistent with each other (with one gap — see Section 7).

---


## 2. Partially Implemented

### Anti-Gaming Flag F8 — Fabricated GPS Detection
The timestamp CV check is implemented and working. However, `f8_speed_cv` is loaded from the env (`AG_F8_SPEED_CV=0.02`) into `Config.AG["f8_speed_cv"]`, but is never referenced anywhere in `_check_f8`. The speed CV sub-check (detecting suspiciously uniform speed profiles) is described by the variable name but not implemented. The flag fires only on timestamp regularity; the speed-pattern half is silently missing.

### Anti-Gaming Flag F5 — Speed Anomaly
Implemented for trail and hike types. `AG_F5_WALK_MAX_SPEED` is loaded from the env into `Config.AG["f5_walk_max_speed"]`, but the `thresholds` dict inside `_check_f5` only maps `"hike"` and `"trail"`. The "walk" activity type check is a dead config key — the walk threshold is loaded but never referenced.

### `UploadConfirmModal.jsx` — Route Upload Confirmation Flow
The modal component is fully implemented (157 lines): shows route preview metrics (distance, elevation gain, density, climb structure), lets the user select activity type, surface tag (0–5), and exposure tag (0–4), and calls `onSubmit` on confirm. The supporting backend endpoint (`/api/routes/preview`) and the `api.previewRoute()` function are both fully implemented. All three pieces exist and are correct.

None of them are wired together. `UploadConfirmModal` is not imported anywhere. `RouteAnalyzer.jsx` calls `api.uploadRoute()` directly on file drop, bypassing the preview step entirely. Surface tag and exposure tag are always stored as 0. The component is 100% dead code.

### Effort Index Baseline
`gps_processor.py` computes `effort_index` as `moving_time_seconds / (total_distance_km * 300)`. The `300` sec/km divisor carries a comment: "5:00 flat pace baseline placeholder". It is a never-replaced placeholder that controls how effort index (and therefore Route Complexity Score) saturates. No env var exists for it.

---


## 3. Scaffolded but Not Functional

### Anti-Gaming Flag F4 — Linear GPS Trace
`_check_f4` exists but is a complete stub. It reads `elevation` values from the elevation profile (which is elevation data, not coordinates), contains the comment "Real implementation would check lat/lon variance", and unconditionally returns `None`. The function was written as a placeholder for a lat/lon spread check that was never implemented. `app.py`'s report export explicitly marks F4 as `"active": False`.

### Anti-Gaming Flags F6 and F7
These have no implementation at all. `AG_F7_MANUAL_UPLOAD=true` exists in `.env` and is loaded into `Config.AG`, but:
- No `_check_f6` or `_check_f7` method exists in `anti_gaming.py`
- Neither flag appears in the `validate()` dispatch logic
- The config value is loaded but consumed by nothing

F6 and F7 are env-var stubs with zero code behind them.

---


## 5. Calibration Status

### Locked (do not change)
| Value | Status |
|---|---|
| RPS weights (0.25/0.30/0.20/0.15/0.10) | Locked per design decision |
| BASE_CLASS_MATRIX (24-cell grid) | Confirmed working per calibration sessions |
| TBS weights (0.50/0.30/0.20) | Confirmed working |
| Grade distance bands (15/40/80km) | Confirmed working |
| Grade elevation bands (10/20/35/60/100 m/km) | Confirmed working |

### Calibrated Against Real Data
| Value | Current Setting | Calibration Session |
|---|---|---|
| Benchmark ceilings (all 6 distance/elevation) | Road 300km/3000m, Trail 200km/8000m, Hike 150km/5000m | Calibration Report 001 — reduced from elite-only theory values to realistic 4-5 sessions/week targets |
| Frequency ceilings | Road/Hike 45, Trail 35 | Calibration Report 001 — proportionally reduced with volume ceilings |
| `CONSISTENCY_EXPONENT` | 0.4 | Calibration Report 001 — softened from 0.5 (was halving already-low volume scores) |
| `TDS_BONUS_RATE` | 0.05 | Calibration Report 001 — reduced from 0.10 (was saturating SE ceiling on 67% of activities) |
| `PC_GRADIENT_RAMP_CEILING` | 0.03 | RMM Calibration Research Report 001 — eliminates flat-terrain PC anomaly |
| `PC_GRADIENT_RAMP_POWER` | 2.0 | Upgraded from linear to quadratic after simulation showing 0.02% flat terrain delta vs 99.8% hilly terrain preservation |
| `PC_CLIMB_IMPACT` | 4.0 | Initial design value, not yet validated against real data |
| `PC_CLIMB_SATURATION` | 3.0 | Initial design value, not yet validated |
| `PC_DESCENT_IMPACT` | 2.0 | Initial design value, not yet validated |
| `PC_DESCENT_SATURATION` | 4.0 | Initial design value, not yet validated |

### Provisional (set but not validated against real data)
| Value | Current Setting | Notes |
|---|---|---|
| `DECAY_HALF_LIFE_DAYS` | 30 | Reasonable default, no real-data calibration |
| `RPS_WINDOW_DAYS` | 90 | Standard training window, no calibration |
| `CROSS_DISCIPLINE_BONUS_PCT` | 0.10 | Set by design, not tested with multi-discipline data |
| `PACE_CONSISTENCY_TRIM_PCT` | 0.10 | Matches reference implementation, not independently validated |
| `PACE_CONSISTENCY_DEFAULT` | 0.85 | Arbitrary proxy for Tier 3 activities |
| PI expected pace baselines | Various | Initial design values, calibration pending |
| RR PI thresholds (A–F: 1.00–0.75) | Set by design | No pass/fail validation done |
| RR coverage and volume multipliers | Set by design | No validation against real race outcomes |
| All TDS thresholds and gain floors | Set by design | Functional but unvalidated |
| All effort descriptor thresholds | Set by design | Functional but unvalidated |
| All anti-gaming thresholds | Set by design | Functional but unvalidated |

---


## 6. Test Data

No test files, test fixtures, or test data sets exist anywhere in the codebase. No `pytest.ini`, no `conftest.py`, no `/tests/` directory, no `.gpx` test files.

The validation approach is empirical: real GPX files are uploaded through the UI, outputs are inspected visually and via the report export JSON. Formula calibration is done by generating the AI report (`/api/report/export`) and analysing the JSON externally.

**Real data in database:** The production database (`data/rmm_formula_lab.db`) contains real training activities uploaded by user "V" and is gitignored. There is no synthetic or reference dataset that would allow reproducing a specific expected output from scratch.

**Implications for a port:** There is no way to verify a ported implementation produces the same outputs as the original without the private database contents. A port would need at minimum a set of reference GPX files with known expected outputs.

---
