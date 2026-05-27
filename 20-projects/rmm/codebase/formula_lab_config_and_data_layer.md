---
title: formula_lab_config_and_data_layer
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: claude_code
tags: [codebase, formula-lab, config, database]
supersedes: ""
related: ["[[formula_lab_architecture_overview]]", "[[formula_lab_engine_files]]", "[[formula_lab_api_and_frontend]]"]
---

# Formula Lab — Config System and Data Layer

## 3. Config System

**File:** `backend/config.py`

**Mechanism:** `load_dotenv()` loads `.env` from project root at module import. Helper `_float(key)` and `_int(key)` read and cast env vars. Every missing key raises `ValueError` at startup — no silent defaults.

**CRITICAL RULE:** All formula values live in `.env`. The Python code contains only structure. `.env` is gitignored and never committed.

### Complete Config Attribute Reference

| Attribute | Env Var(s) | Type | Purpose |
|---|---|---|---|
| `RPS_WEIGHTS` | `RPS_WEIGHT_{DISTANCE/SPEED_EFFICIENCY/ELEVATION/PACE_CONSISTENCY/FREQUENCY}` | dict[str, float] | Component weights (must sum to 1.0). Locked: 0.25/0.30/0.20/0.15/0.10 |
| `CEILINGS["road/trail/hike"]` | `CEILING_{T}_{DISTANCE_KM/PACE_SEC_PER_KM/SPEED_EFFICIENCY_KMH/ELEVATION_M/FREQUENCY}` | dict[str, dict] | 90-day benchmark maximums per discipline. Score = value/ceiling × 100 |
| `DECAY_HALF_LIFE` | `DECAY_HALF_LIFE_DAYS` | float | Days until activity weight halves (default: 30) |
| `DECAY_LAMBDA` | computed | float | `ln(2) / DECAY_HALF_LIFE` |
| `RPS_WINDOW_DAYS` | `RPS_WINDOW_DAYS` | int | Activity lookback window (default: 90) |
| `CONSISTENCY_EXPONENT` | `CONSISTENCY_EXPONENT` | float | Power on raw consistency ratio — lower = gentler penalty (default: 0.4) |
| `CROSS_DISCIPLINE_BONUS_PCT` | `CROSS_DISCIPLINE_BONUS_PCT` | float | L3 bonus if ≥2 disciplines active (default: 0.10) |
| `PACE_CONSISTENCY_TRIM_PCT` | `PACE_CONSISTENCY_TRIM_PCT` | float | Fraction trimmed each end in Tier 1 (default: 0.10) |
| `PACE_CONSISTENCY_MIN_SPLITS` | `PACE_CONSISTENCY_MIN_SPLITS` | int | Legacy alias for MIN_SPLITS_FULL |
| `PACE_CONSISTENCY_MIN_SPLITS_FULL` | `PACE_CONSISTENCY_MIN_SPLITS_FULL` | int | Min splits for Tier 1 (default: 5) |
| `PACE_CONSISTENCY_MIN_SPLITS_PARTIAL` | `PACE_CONSISTENCY_MIN_SPLITS_PARTIAL` | int | Min splits for Tier 2; below = Tier 3 (default: 2) |
| `PACE_CONSISTENCY_DEFAULT` | `PACE_CONSISTENCY_DEFAULT` | float | Proxy for Tier 3 activities in RPS (default: 0.85) |
| `MOVING_THRESHOLDS` | `MOVING_THRESHOLD_{ROAD/TRAIL/HIKE}` | dict[str, float] | Min km/h to count as moving (1.5/1.0/0.5) |
| `DEM_SMOOTHING_THRESHOLD` | `DEM_SMOOTHING_THRESHOLD_M` | float | Elevation changes below this are smoothed (default: 2m) |
| `GRADE_DISTANCE` | `GRADE_DISTANCE_{SHORT/MEDIUM/LONG}_MAX` | dict[str, float] | Distance band cutoffs in km: 15/40/80 |
| `GRADE_ELEVATION` | `ED_BAND_{LOW/ROLLING/HILLY/STEEP/MOUNTAIN}_MAX` | dict[str, float] | ED band cutoffs in m/km: 10/20/35/60/100 |
| `BASE_CLASS_MATRIX` | `BASE_CLASS_MATRIX` | dict (JSON) | 24-cell matrix: `"Short_Low"` → `"F"` etc. Stored as JSON string in .env |
| `TBS_MODIFIER` | `TBS_MODIFIER_TIER{1/2}_THRESHOLD` | dict[str, float] | TBS thresholds for +1/+2 class modifier: 80/95 |
| `GAIN_MODIFIER` | `GAIN_MODIFIER_TIER{1/2}_{GAIN/DIST}` | dict[str, float] | Elevation gain + distance thresholds: 600m/15km, 1200m/25km |
| `MODIFIER_MAX` | `MODIFIER_MAX` | int | Maximum class modifier value (2) |
| `TDS` | `TDS_{DIVISOR/MIN/MAX/GAIN_FLOOR_T*_*}` | dict | TDS params: divisor=10, range 1–10, two gain floor adjustments |
| `EFFORT` | `EFFORT_*` | dict[str, float] | All effort descriptor thresholds |
| `PILLAR3` | `PILLAR3_*` | dict[str, float] | Climb structure classification thresholds |
| `CLIMB_MIN_GAIN` | `CLIMB_MIN_GAIN_M` | float | Min gain to record a climb (30m) |
| `CLIMB_END_DESCENT` | `CLIMB_END_DESCENT_M` | float | Descent required to close a climb (10m) |
| `TBS_WEIGHTS` | `TBS_WEIGHT_{ELEV_DENSITY/MAX_GRADIENT/GRADIENT_VARIABILITY}` | dict[str, float] | Terrain Brutality composite weights: 0.50/0.30/0.20 |
| `RCS_WEIGHTS` | `RCS_WEIGHT_{CLIMB_COUNT/EFFORT_INDEX/SPLIT_DEVIATION}` | dict[str, float] | Route Complexity composite weights: 0.40/0.35/0.25 |
| `GRADIENT_SEGMENT_LENGTH` | `GRADIENT_SEGMENT_LENGTH_M` | int | Window size for gradient calculation (100m) |
| `MAX_GRADIENT_WINDOW` | `MAX_GRADIENT_WINDOW_M` | int | Window size for max sustained gradient (500m) |
| `PI_EXPECTED` | `PI_EXPECTED_{ROAD/TRAIL/HIKE}_{A–F}` | nested dict[str, dict[str, float]] | Expected sec/km per discipline per class (A–F); baseline for Race Readiness PI check |
| `RR_PI_THRESHOLDS` | `RR_PI_THRESHOLD_{A–F}` | dict[str, float] | Min PI to pass race readiness check per class: 1.00/0.95/0.90/0.85/0.80/0.75 |
| `RR_RECENCY_WINDOW` | `RR_RECENCY_WINDOW_DAYS` | int | Recency check lookback (21 days) |
| `RR_RECENCY_MIN` | `RR_RECENCY_MIN_ACTIVITIES` | int | Min activities in recency window (3) |
| `RR_ELEVATION_MULTIPLIER` | `RR_ELEVATION_MULTIPLIER` | float | Fraction of route elevation needed in training history (0.6) |
| `RR_ELEVATION_AUTO_PASS_THRESHOLD` | `RR_ELEVATION_AUTO_PASS_THRESHOLD` | float | Routes below this elevation auto-pass the elevation check (50m) |
| `RR_COVERAGE_PCT` | `RR_COVERAGE_PCT_{UNDER_10/10_25/25_50/50_100/OVER_100}` | dict[str, float] | Single-effort coverage fractions by route distance band |
| `RR_VOLUME_MULT` | `RR_VOLUME_MULT_{UNDER_10/10_25/25_50/50_100/OVER_100}` | dict[str, float] | Volume multiplier (total km / route km) by band |
| `AG` | `AG_F*_*` | dict[str, float] | All anti-gaming flag thresholds |
| `PC_CLIMB_IMPACT` | `PC_CLIMB_IMPACT` | float | Climb impact coefficient for gradient-normalised PC (default: 4.0) |
| `PC_CLIMB_SATURATION` | `PC_CLIMB_SATURATION` | float | Saturation denominator for climbs (default: 3.0) |
| `PC_DESCENT_IMPACT` | `PC_DESCENT_IMPACT` | float | Descent impact coefficient (default: 2.0) |
| `PC_DESCENT_SATURATION` | `PC_DESCENT_SATURATION` | float | Saturation denominator for descents (default: 4.0) |
| `PC_GRADIENT_RAMP_CEILING` | `PC_GRADIENT_RAMP_CEILING` | float | Gradients below this are ramped toward zero (default: 0.03 = 3%) |
| `PC_GRADIENT_RAMP_POWER` | `PC_GRADIENT_RAMP_POWER` | float | Exponent for the ramp curve — 2.0 = quadratic (default: 2.0) |
| `TDS_BONUS_RATE` | `TDS_BONUS_RATE` | float | SE bonus multiplier per TDS point — `raw_se × (1 + rate × tds)` (default: 0.05) |
| `LEVELS` | `LEVEL_{FOUNDATION/ACTIVE/ATHLETE/COMPETITOR}_MAX` | list[dict] | RPS band definitions: Foundation 0–20, Active 21–50, Athlete 51–70, Competitor 71–85, Elite 86–100 |

**Class methods:**

`Config.get_level(rps)` → `{name, floor, ceiling, position_pct}` — returns the band containing `rps`. `position_pct` = progress through the band, 0–100%.

`Config.to_dict()` → full serialised dict of all config values, used by `/api/config` and the calibration panel.

---


## 4. Data Layer

**Engine:** SQLite via Python `sqlite3`. WAL mode enabled. Foreign keys on. File: `data/rmm_formula_lab.db` (relative to project root, created on first startup).

Schema is managed inline in `database.init_db()` — `CREATE TABLE IF NOT EXISTS` + `ALTER TABLE` statements wrapped in `try/except OperationalError` for idempotent migrations. No Alembic, no migration files.

### Tables

**`profiles`**

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | UUID |
| `name` | TEXT NOT NULL | Display name (case-insensitive unique enforced in code) |
| `description` | TEXT | Optional notes |
| `created_at` | TEXT | ISO timestamp |

Seeded on first run: "V" (personal), "Elite", "Mid-Pack", "Beginner".

---

**`activities`**

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | UUID |
| `filename` | TEXT | Original GPX filename |
| `activity_type` | TEXT NOT NULL DEFAULT 'trail' | road / trail / hike |
| `purpose` | TEXT NOT NULL DEFAULT 'training' | training / route |
| `date` | TEXT | Activity start time (ISO) from GPX first timestamp |
| `created_at` | TEXT | Upload timestamp |
| `raw_data` | JSON NOT NULL | Full `GPSStreamProcessor.parse_gpx()` output dict |
| `flags` | JSON | Anti-gaming flags list |
| `custom_name` | TEXT | User-set display name (migration) |
| `profile_id` | TEXT | FK → profiles.id (migration) |
| `raw_gpx` | TEXT | Original GPX stored for re-processing on type change (migration) |

Indexes on `activity_type`, `date`, `purpose`.

Both training activities and route activities get a `route_analyses` entry. Training activities are graded for the PI check in Race Readiness.

---

**`route_analyses`**

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | UUID |
| `activity_id` | TEXT NOT NULL | FK → activities.id |
| `created_at` | TEXT | ISO timestamp |
| `grade_data` | JSON NOT NULL | Full `RouteGrader.grade_route()` output dict |
| `surface_tag` | INTEGER DEFAULT 0 | 0–5 surface quality scale |
| `exposure_tag` | INTEGER DEFAULT 0 | 0–4 exposure/consequence scale |

Index on `activity_id`.

---

**`rps_snapshots`**

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | UUID |
| `activity_type` | TEXT NOT NULL | road / trail / hike |
| `created_at` | TEXT | ISO |
| `reference_date` | TEXT | ISO date of calculation |
| `rps_data` | JSON NOT NULL | Full `RPSEngine.calculate_rps()` output dict |

---

**`calibration_presets`**

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | UUID |
| `name` | TEXT NOT NULL | Preset label |
| `created_at` | TEXT | ISO |
| `config_data` | JSON NOT NULL | Config override dict |

---

### Key Query Patterns

`get_all_activities(activity_type, purpose, profile_id)` — Dynamic WHERE. **Backward compat:** profile "V" also owns activities where `profile_id IS NULL` (pre-multi-profile data). Pattern: `profile_id = ? OR profile_id IS NULL`.

`get_all_routes_with_grades()` — JOIN with ROW_NUMBER window function to fetch the latest `route_analysis` per activity.

`get_activity(id)` → dict with `raw_data` and `flags` JSON-decoded, `display_name = custom_name OR filename`.

`save_activity(gps_data, activity_type, purpose, filename, flags, profile_id, raw_gpx)` — Uses `gps_data["start_time"]` as the `date` column.

`update_activity_type(activity_id, activity_type, gps_data)` — If `gps_data` provided (re-processed), replaces `raw_data`. Otherwise patches `activity_type` inside existing JSON.

`delete_profile(profile_id)` — Cascades: deletes `route_analyses`, then training `activities`, then the profile. Route activities (purpose='route') are NOT deleted.

---
