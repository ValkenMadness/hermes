---
title: formula_lab_engine_files
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: claude_code
tags: [codebase, formula-lab, engine, python]
supersedes: ""
related: ["[[formula_lab_architecture_overview]]", "[[gps_stream_processor]]", "[[route_grading_system_v3]]", "[[runner_performance_score_rps]]", "[[race_readiness_engine]]", "[[formula_lab_build_status_overview]]", "[[formula_lab_config_and_data_layer]]", "[[gps_processing_pipeline]]"]
---

# Formula Lab — The Four Engine Files

## 2. The Four Engine Files

### 2.1 `backend/gps_processor.py` — GPS Stream Processor

**Purpose:** Core computation unit. Parses raw GPX XML into every derived metric consumed by all other systems. Everything downstream reads its output dict.

**Module-level helper:**

```python
haversine(lat1, lon1, lat2, lon2) -> float
```
Earth-radius Haversine formula. Returns distance in metres between two GPS coordinates.

**Class: `GPSStreamProcessor`**

```python
__init__(config_override: dict = None)
```
Accepts a runtime config dict to override defaults. Used by the calibration panel for live previews.

```python
_cfg(key, default)
```
Looks up key in `config_override` first, falls back to `default`.

---

**Main entry point:**

```python
parse_gpx(gpx_content: str) -> dict
```

Input: raw GPX XML string.

**Full pipeline (in order):**
1. Parse XML, detect GPX namespace URI.
2. `_extract_trackpoints()` — list of point dicts with `lat`, `lon`, `ele`, `time`, `hr`, and cumulative distance.
3. DEM correction via `DEMLookup.correct_profile()` — attaches `ele_corrected` to each point.
4. `_calculate_segments()` — per-consecutive-point-pair: distance, time, speed.
5. Total distance from segment sum.
6. Elapsed time from first/last timestamp.
7. `_calculate_moving_time()` — sums segment time for segments above speed threshold.
8. `_calculate_elevation_metrics()` — total gain/loss, density, min/max from corrected elevations.
9. RMM avg pace and speed (distance / moving_time).
10. `_calculate_km_splits()` — per-km time, pace, gradient.
11. `_calculate_pace_consistency()` — three-tier CV-based score.
12. `_calculate_gradient_metrics()` — gradient variability (StdDev), max sustained gradient (sliding window).
13. `_detect_climbs()` + `_classify_climb_structure()`.
14. `_calculate_terrain_brutality()` — weighted composite of ED, max gradient, gradient variability.
15. `_calculate_tds_score()` — TBS → TDS 1–10.
16. `_calculate_route_complexity()` — weighted composite of climb count, effort index, split deviation.
17. `_coordinate_revisit_pct()` — grid-based duplicate visit detection.
18. `_extract_hr()` — avg/max HR from GPX extensions if present.

**Returns dict with 40+ keys:**
`total_distance_km`, `total_distance_m`, `elapsed_time_seconds`, `rmm_moving_time_seconds`, `rmm_avg_speed_kmh`, `rmm_avg_pace_sec_per_km`, `rmm_avg_pace_formatted`, `total_elevation_gain`, `total_elevation_loss`, `elevation_density`, `min_elevation`, `max_elevation`, `dem_corrected`, `gradient_variability`, `max_sustained_gradient`, `gradient_segments`, `climb_count`, `climbs`, `climb_structure`, `km_splits`, `pace_consistency_score`, `pace_consistency_tier`, `pace_consistency_cv`, `split_deviation`, `terrain_brutality_score`, `terrain_difficulty_score`, `effort_index`, `route_complexity_score`, `coordinate_revisit_pct`, `avg_hr`, `max_hr`, `start_time`, `timestamp_estimated`, `has_timestamps`, `start_lat`, `start_lon`, `elevation_profile`, `coordinate_stream`, `point_count`.

---

**Internal methods:**

`_detect_namespace(root)` — Extracts GPX XML namespace URI.

`_extract_trackpoints(root, ns)` — Iterates `trk/trkseg/trkpt`. Returns list of point dicts with `lat`, `lon`, `ele`, `time`, `hr`, and cumulative `distance_m`.

`_calculate_segments(points)` — Pairs consecutive points, produces `{distance_m, time_seconds, speed_ms}` per pair.

`_calculate_moving_time(segments, threshold_ms)` — Filters segments by speed threshold, sums time. Threshold from `Config.MOVING_THRESHOLDS` per activity type.

`_calculate_elevation_metrics(points, elevations, distance_km)` — Forward-difference sums of gains/losses. Density = total_gain / distance_km.

`_calculate_km_splits(points, segments)`:
- Accumulates time until each 1 km boundary.
- Gradient per split = `(elevation_at_split_end − elevation_at_split_start) / 1000.0` (metres per metre, i.e. 0.03 = 3%).
- Handles partial final km with `partial: True` flag.
- Each split: `{km, time_seconds, pace_sec_per_km, pace_formatted, gradient, [partial: True]}`.

`_calculate_pace_consistency(km_splits)` — Three-tier:
- Tier 3 (`n < 2`): returns `{score: None, tier: 3}`.
- Tier 2 (`2 ≤ n < 5`): CV from all full splits, no trimming.
- Tier 1 (`n ≥ 5`): sorts paces, trims 10% fastest + slowest, CV from middle 80%.
- Score = `max(0, 1 − CV)`. Population std dev (`/ n`, not `/ n-1`).

`_calculate_gradient_metrics(points, elevations, total_distance_m)` — 100m windows (configurable). Gradient variability = StdDev of all window gradients. Max sustained = highest mean gradient over any 500m sliding window (ascent-only).

`_detect_climbs(elevations, points)` — State machine: enters `in_climb` on any upward step, tracks local high, exits when descent > `CLIMB_END_DESCENT_M=10m`, records climb if gain ≥ `CLIMB_MIN_GAIN_M=30m`. Each climb: `{start_idx, end_idx, start_elevation, peak_elevation, gain, gain_pct_of_total, start_km, end_km}`.

`_classify_climb_structure(climbs, total_gain, points, elevations)` — Ordered decision tree:
1. Technical: ≥4 climbs with average inter-climb descent < 50% of avg climb gain.
2. Single Ascent: one climb >70% of total gain AND ≤2 climbs total.
3. Stacked: >60% of gain in first or second half.
4. Even/Rolling: no single climb >30% of total.
Returns string label.

`_calculate_terrain_brutality(elevation_density, max_sustained_gradient, gradient_variability)` — Normalises each input to 0–100, then: `score = ED×0.50 + max_grad×0.30 + grad_var×0.20`. Returns 0–100.

`_calculate_tds_score(tbs, elevation_gain, distance_km)`:
- `raw = round(tbs / TDS_DIVISOR)`, clamped to `[TDS_MIN, TDS_MAX]` (1–10).
- Gain floor T1: if gain ≥ 600m AND dist ≥ 15km → floor 5.
- Gain floor T2: if gain ≥ 1200m AND dist ≥ 25km → floor 7.

`_calculate_route_complexity(climb_count, effort_index, split_deviation)` — Normalises: climb_count/10, effort_index/3, split_deviation/120. Weighted: 40%/35%/25%.

`_coordinate_revisit_pct(points)` — 20m grid (0.0002° cells), returns fraction of revisited cells.

`_extract_hr(points)` — Filters points with `hr` field, returns `{avg, max, min, count}`.

`_format_pace(seconds_per_km)` → `"M:SS"` string.

---

### 2.2 `backend/route_grader.py` — Route Grader V3

**Purpose:** Converts GPS processor output into a difficulty class (A–F), TDS (1–10), effort descriptor, and route type tag. GPS-only inputs — no curator tags.

**Module constant:** `CLASS_ORDER = ["F", "E", "D", "C", "B", "A"]` — index 0 = easiest (F), index 5 = hardest (A).

**Class: `RouteGrader`**

```python
grade_route(gps_data: dict) -> dict
```

Input: output of `GPSStreamProcessor.parse_gpx()`.

**Pipeline:**
1. `_classify_distance(distance_km)` → distance band.
2. `_classify_elevation_density(elevation_density)` → elevation band.
3. `_base_class_from_matrix(dist_band, elev_band)` → lookup in `Config.BASE_CLASS_MATRIX`.
4. `_apply_modifiers(tbs, elevation_gain, distance_km)` → `(modifier: int 0–2, source: str)`.
5. `final_index = base_class_index + modifier`, clamped to `[0, 5]`.
6. TDS from `gps_data["terrain_difficulty_score"]` (pre-computed) or fallback `_calculate_tds()`.
7. `_classify_effort_descriptor(elevation_density, max_gradient, climb_count)`.
8. `_assign_route_tag(distance_km, elevation_density, climb_structure)`.

**Returns:**
```python
{
    "difficulty_class": "B",
    "terrain_difficulty_score": 7,
    "effort_descriptor": "Sustained Ascent",
    "route_type_tag": "Strength",
    "grade_display": "Class B · 7/10 / Sustained Ascent · 28.4 km · 1240m · 44 m/km",
    "pillar1_distance": "Medium",
    "pillar2_elevation": "Mountain",
    "pillar3_climb_structure": "Stacked",
    "base_class": "A",
    "modifier": 0,
    "modifier_source": "none"
}
```

---

**Internal methods:**

`_classify_distance(distance_km)`:
- Short: < 15 km
- Medium: < 40 km
- Long: < 80 km
- Ultra: ≥ 80 km

`_classify_elevation_density(density)`:
- Low: < 10 m/km
- Rolling: < 20 m/km
- Hilly: < 35 m/km
- Steep: < 60 m/km
- Mountain: < 100 m/km
- Extreme: ≥ 100 m/km

`_base_class_from_matrix(distance_band, elevation_band)` — Key format: `"Short_Low"`. Looks up `Config.BASE_CLASS_MATRIX`. Current full matrix:

| | Low | Rolling | Hilly | Steep | Mountain | Extreme |
|---|---|---|---|---|---|---|
| **Short** | F | E | D | C | B | A |
| **Medium** | E | D | C | B | A | A |
| **Long** | D | D | C | B | A | A |
| **Ultra** | D | C | B | A | A | A |

`_apply_modifiers(tbs, elevation_gain, distance_km)`:
- TBS path: TBS ≥ 95 → +2; TBS ≥ 80 → +1; else 0.
- Gain path: gain ≥ 1200m AND dist ≥ 25km → +2; gain ≥ 600m AND dist ≥ 15km → +1; else 0.
- Takes the higher of the two paths. Cap at `MODIFIER_MAX=2`.
- Source: `"tbs"`, `"gain"`, `"tbs_gain_tied"`, or `"none"`.

`_classify_effort_descriptor(elevation_density, max_gradient, climb_count)` — Decision tree (in priority order):
1. ED < 10 → "Flat"
2. ED < 20 → "Undulating"
3. ED < 35 → "Hilly"
4. ED ≥ 100 AND (max_gradient ≥ 40 OR climb_count ≥ 4) → "Relentless Ascent"
5. 15 ≤ max_gradient < 40 AND ED < 100 → "Sustained Ascent"
6. ED ≥ 60 → "Big Push"
7. ED < 60 AND max_gradient < 15 → "Steady Rise"
8. Default → "Hilly"

`_assign_route_tag(distance_km, elevation_density, climb_structure)`:
1. ED ≥ 35 → "Strength"
2. dist ≥ 80km → "Endurance"
3. dist < 15km AND ED < 10 → "Recovery"
4. dist < 40km AND ED < 20 → "Tempo"
5. dist ≥ 40km AND 20 ≤ ED < 35 → "Mental Grind"
6. Default → "Aerobic"

---

### 2.3 `backend/rps_engine.py` — RPS Engine

**Purpose:** Calculates Runner Performance Score (0–100) from a list of activity dicts. Implements exponential decay, consistency modifier, gradient-normalised pace consistency (RPS-8), and TDS-adjusted speed efficiency (RPS-9).

**RPS weights (locked, must sum to 1.0):** Distance 0.25 · Speed Efficiency 0.30 · Elevation 0.20 · Pace Consistency 0.15 · Frequency 0.10.

---

**Module-level functions:**

```python
_gradient_adjustment(
    gradient: float,
    climb_impact: float,
    climb_sat: float,
    descent_impact: float,
    descent_sat: float,
    ramp_ceiling: float = 0.0,
    ramp_power: float = 1.0,
) -> float
```
- Saturation curve: `adj = impact × abs_g × (1 / (1 + sat × abs_g))`.
- Quadratic ramp: if `abs_g < ramp_ceiling`, scales `adj` by `(abs_g / ramp_ceiling)^ramp_power` (eliminates flat-terrain anomaly where micro-gradients produced artificial residuals).
- Returns signed float: positive for climbs (slows expected pace), negative for descents.

```python
_compute_gradient_pc(
    km_splits: list,
    min_partial: int,
    min_full: int,
    trim_pct: float,
    climb_impact: float,
    climb_sat: float,
    descent_impact: float,
    descent_sat: float,
    ramp_ceiling: float = 0.0,
    ramp_power: float = 1.0,
) -> Optional[float]
```
- Gradient-normalised pace consistency. Mirrors the three-tier system in `gps_processor.py` but uses gradient-residuals instead of raw paces.
- Tier 3 (`n < min_partial`): returns None.
- Tier 2 (`min_partial ≤ n < min_full`): all splits, no trimming.
- Tier 1 (`n ≥ min_full`): value-sorted trimming — sorts indices by pace value, removes trim_pct fastest and slowest, restores original order to preserve pace-gradient pairing. Matches `gps_processor._calculate_pace_consistency()` exactly.
- For each retained split: `expected_pace = mean_pace × (1 + _gradient_adjustment(...))`. Residual = `actual_pace − expected_pace`.
- CV = StdDev(residuals) / mean_pace. Uses **population std dev** (`/ n`, not `/ n-1`) — matches gps_processor.
- Score = `max(0, min(1, 1 − CV))`.
- Exported at module level so `app.py` can import it directly.

---

**Class: `RPSEngine`**

```python
__init__(config_override: dict = None)
```
Optional override dict for calibration panel live previews.

```python
_cfg(key, default)
```
Checks `config_override` first, falls back to `default`.

```python
calculate_rps(
    activities: list[dict],
    activity_type: str = "trail",
    reference_date: Optional[datetime] = None,
) -> dict
```

**Full pipeline:**

1. Filter activities to matching `activity_type` within `RPS_WINDOW_DAYS` (default: 90).
2. For each activity: `decay_weight = exp(−ln(2) / half_life × days_ago)`.
3. Pre-compute per activity:
   - `_pc_normalised` = `_compute_gradient_pc()` from stored `km_splits`.
   - `raw_se = total_distance_km / (rmm_moving_time_seconds / 3600)`.
   - `_adjusted_se = raw_se × (1 + TDS_BONUS_RATE × tds)`, capped at ceiling.
4. **Distance score**: `sum(distance_km × decay_weight) / ceiling_km × 100`, capped at 100.
5. **Speed Efficiency score**: `sum(_adjusted_se × decay_weight) / sum(decay_weight) / ceiling × 100`. Denominator uses ALL activities (not just those with valid SE).
6. **Elevation score**: `sum(elevation_gain × decay_weight) / ceiling × 100`.
7. **Pace Consistency score**:
   - Collect activities with valid `_pc_normalised` or fallback `pace_consistency_score` → compute weighted average `tier12_avg`.
   - Tier 3 activities (no valid PC) substitute `tier12_avg` as proxy.
   - Final `pace_consistency_avg` = decay-weighted mean over all activities.
   - Score = `pace_consistency_avg × 100`.
8. **Frequency score**: `sum(decay_weight) / frequency_ceiling × 100`.
9. **Consistency Modifier**:
   - `expected_decay_sum = sum(expected_rate × exp(−lambda × day))` for each day in window.
   - `raw_consistency = actual_decay_sum / expected_decay_sum`.
   - `modifier = min(1.0, raw_consistency ^ CONSISTENCY_EXPONENT)`.
   - Applied to Distance and Elevation scores only (multiplied). PC, SE, Frequency unaffected.
10. **RPS** = weighted sum of five (possibly modified) component scores, capped at 100.
11. Level via `Config.get_level(rps)`.

**Returns:**
```python
{
    "rps": float,
    "activity_type": str,
    "level": {"name": str, "floor": int, "ceiling": int, "position_pct": float},
    "window_days": int,
    "activity_count": int,
    "reference_date": str,
    "components": {
        "distance": {"raw_value", "ceiling", "score", "score_modified", "weight", "contribution", "unit"},
        "speed_efficiency": {"raw_value", "ceiling", "score", "weight", "contribution", "unit"},
        "elevation": {"raw_value", "ceiling", "score", "score_modified", "weight", "contribution", "unit"},
        "pace_consistency": {"raw_value", "score", "weight", "contribution"},
        "frequency": {"raw_value", "ceiling", "score", "weight", "contribution", "unit"},
    },
    "consistency": {"raw": float, "modifier": float, "exponent": float},
    "decay": {"half_life_days": float, "lambda": float},
    "activities": [
        {
            "date", "days_ago", "decay_weight", "distance_km", "elevation_gain",
            "pace_sec_per_km", "speed_kmh", "pace_consistency_raw",
            "pace_consistency_normalised", "raw_se_kmh", "adjusted_se_kmh", "tds_used"
        }, ...
    ]
}
```

```python
calculate_all_layers(activities: list[dict], reference_date: datetime = None) -> dict
```

- **Layer 1**: Calls `calculate_rps()` independently for road, trail, hike.
- **Layer 2**: Intentionally removed. Combining disciplines at a single benchmark caused systematic +19–31% score inflation (road speeds scoring against trail ceilings, combined volumes exceeding single-discipline ceilings).
- **Layer 3**: Decay-weighted average of L1 scores + optional cross-discipline bonus. Floored at best L1.
  - `bonus = weighted_avg × CROSS_DISCIPLINE_BONUS_PCT` (only if ≥2 disciplines active).
  - `overall_rps = max(best_l1_rps, weighted_avg + bonus)`, capped at 100.

Returns `{layer1: {road, trail, hike}, layer3_overall: {...}}`.

---

### 2.4 `backend/race_readiness.py` — Race Readiness Engine

**Purpose:** Five-check pass/fail system assessing whether a training history is sufficient for a specific route. Stateless — read-only, returns assessment dict.

**Module-level helpers:**

`_CLASS_ORDER = {"F":0, "E":1, "D":2, "C":3, "B":4, "A":5}` — used for class comparison.

`_class_gte(activity_class, target_class)` — True if activity class ≥ target class.

`_get_base_class(distance_km, elevation_density)` — Mirrors `Config.BASE_CLASS_MATRIX` logic to get base class for an activity (used for PI check, avoids requiring grade_data for training activities).

`_distance_band(distance_km)` → `"under_10"`, `"10_25"`, `"25_50"`, `"50_100"`, or `"over_100"`.

---

**Five check functions** (each returns `{check, status, progress_pct, ...check-specific fields}`):

**`_check_distance_coverage(route_data, activities, config)`**
- Finds longest single training activity (by `total_distance_km`).
- Required = `route_km × coverage_pct[band]`.
- Coverage pcts: under 10km=80%, 10–25km=75%, 25–50km=70%, 50–100km=60%, >100km=50%.
- PASS if `best_km ≥ required_km`.

**`_check_volume_load(route_data, activities, config)`**
- Sums all training activity distances.
- Required = `route_km × volume_multiplier[band]`.
- Multipliers: 3.0, 2.5, 2.0, 1.5, 1.2.
- PASS if `actual_km ≥ required_km`.

**`_check_performance_index(route_data, activities, config)`**
- For each activity: derive `base_class` from GPS data via `_get_base_class()`. Look up `Config.PI_EXPECTED[activity_type][base_class]` (expected sec/km). `PI = expected_time / moving_time` (>1.0 = faster than baseline).
- Qualifies if `_class_gte(activity_base_class, target_class)` AND `PI ≥ required_pi`.
- Required PI by target class: A=1.00, B=0.95, C=0.90, D=0.85, E=0.80, F=0.75.
- PASS if any qualifying activity exists.

**`_check_recency(activities, config, reference_date)`**
- Counts activities within last `RR_RECENCY_WINDOW_DAYS=21` days.
- PASS if count ≥ `RR_RECENCY_MIN_ACTIVITIES=3`.

**`_check_elevation_coverage(route_data, activities, config)`**
- AUTO_PASS if route elevation < `RR_ELEVATION_AUTO_PASS_THRESHOLD=50m`.
- Required = `route_elevation × RR_ELEVATION_MULTIPLIER=0.6`.
- PASS if sum of all activity elevation gains ≥ required.

```python
assess_readiness(route_data: dict, training_activities: list, reference_date: datetime = None) -> dict
```
Runs all five checks. Verdict: 5/5 → "READY", 4/5 → "CLOSE", else → "NOT YET".

Returns:
```python
{
    "route": {...},
    "verdict": "READY" | "CLOSE" | "NOT YET",
    "checks_passed": int,
    "checks_total": 5,
    "checks": [five check result dicts],
    "summary_message": str
}
```

---

### 2.5 `backend/anti_gaming.py` — Anti-Gaming Validator

**Purpose:** Validates each uploaded activity against 9 flag rules. Called on every upload before storage.

**Class: `AntiGamingValidator`**

```python
validate(activity: dict, all_activities: list[dict] = None) -> list[dict]
```
Returns list of flag dicts: `{flag, name, description, severity}`.

Severities: `review`, `suppress`, `merge`, `cap_elevation`, `info`.

**Flags:**

| Flag | Name | Condition | Severity |
|---|---|---|---|
| F1 | Type/GPS Mismatch | Trail declared but ED < 5 m/km | review |
| F2 | Impossible Location Jump | Starts >10km from any activity within 30 min | suppress |
| F3 | Split Activity | Starts within 500m of activity within 2hrs with <30% pace diff (min 2km) | merge |
| F4 | Linear GPS Trace | Placeholder — not yet implemented | — |
| F5 | Speed Anomaly | Hike >10 km/h or Trail >20 km/h | review |
| F8 | Fabricated GPS | Timestamp CV < 0.01 AND speed CV < 0.02 (on ≥2km, ≥3 splits) | suppress |
| F9 | Elevation Yo-Yo | ED > 80 m/km AND coordinate revisit > 40% | cap_elevation |
| F10 | Short Activity Failure | Tier 2/3 only: split speed > teleport limit, or speed < threshold, or movement ratio < 0.4 | review |

---

### 2.6 Engine Interconnections and Call Chains

**Upload — training activity:**
```
POST /api/activities/upload
  → GPSStreamProcessor.parse_gpx()           # produces gps_data dict
  → AntiGamingValidator.validate()            # validates gps_data + existing activities
  → db.save_activity()                        # stores gps_data as raw_data JSON
  → RouteGrader.grade_route(gps_data)         # uses tbs, elevation_density, etc.
  → db.save_route_analysis()                  # stores grade_data JSON
```

**Upload — route:**
```
POST /api/routes/upload
  → GPSStreamProcessor.parse_gpx()           # same pipeline
  → db.save_activity(purpose='route')
  → RouteGrader.grade_route(gps_data)
  → db.save_route_analysis()
```

**RPS calculation:**
```
POST /api/rps/calculate
  → db.get_all_activities(purpose='training', profile_id=...)
  → RPSEngine.calculate_rps(activities, activity_type)
      → for each activity: _compute_gradient_pc(km_splits, ...)
      → Config.get_level(rps)
  → db.save_rps_snapshot()
```

**Race readiness:**
```
GET /api/race-readiness?route_id=&profile_id=
  → db.get_activity(route_id)               # loads route raw_data
  → db.get_route_analysis(route_id)         # loads grade_data (difficulty_class)
  → db.get_all_activities(purpose='training', profile_id=...)
  → RaceReadiness.assess_readiness(route_data, training_activities)
      → _get_base_class()                   # mirrors Config.BASE_CLASS_MATRIX logic
      → _check_performance_index()          # uses Config.PI_EXPECTED baselines
```

**Shared data bus:** The `gps_data` dict from `parse_gpx()` is stored verbatim as `raw_data` JSON in the `activities` table. All downstream systems read from this stored blob without re-processing (except on activity type change, which re-runs the GPS processor). The `km_splits` nested within it are used by RPSEngine for gradient-normalised PC and by AntiGamingValidator for F8/F10.

---
