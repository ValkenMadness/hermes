---
title: formula_lab_api_and_frontend
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: claude_code
tags: [codebase, formula-lab, api, frontend, react]
supersedes: ""
related: ["[[formula_lab_architecture_overview]]", "[[formula_lab_config_and_data_layer]]", "[[formula_lab_build_status_overview]]"]
---

# Formula Lab — API Layer, Frontend, Testing

## 5. API Layer

**Framework:** FastAPI. CORS allows `localhost:5173` and `:3000`. Auto-generated docs at `/docs`.

### Endpoints

#### Profiles
| Method | Path | Parameters | Returns |
|---|---|---|---|
| GET | `/api/profiles` | — | List of all profiles with `activity_count` |
| POST | `/api/profiles` | Body: `{name, description}` | New profile dict (201) |
| PATCH | `/api/profiles/{profile_id}/name` | Body: `{name}` | `{id, name}` |
| DELETE | `/api/profiles/{profile_id}` | — | `{deleted_activities: int}`. Default "V" profile returns 400. |

#### Race Readiness
| Method | Path | Parameters | Returns |
|---|---|---|---|
| GET | `/api/race-readiness` | Query: `route_id`, `profile_id` | Full readiness assessment (verdict, 5 checks, summary) |

#### Route Analyzer (purpose='route')
| Method | Path | Parameters | Returns |
|---|---|---|---|
| POST | `/api/routes/preview` | Form: `file` (GPX) | Quick metrics dict, not stored: filename, distance_km, elevation_gain_m, elevation_density, climb_structure, climb_count, timestamp_estimated |
| POST | `/api/routes/upload` | Form: `file`, `activity_type` | `{activity_id, gps_data, grade}` |
| GET | `/api/routes` | — | `{routes: [...], count}` — list with grade summary |
| GET | `/api/routes/{route_id}` | — | `{activity, route_analysis}` — full detail |
| PATCH | `/api/routes/{route_id}/type` | Body: `{activity_type}` | `{activity, route_analysis}` — re-processes GPX, re-grades |
| DELETE | `/api/routes/{route_id}` | — | `{deleted: route_id}` |
| DELETE | `/api/routes` | — | `{deleted: "all routes"}` |

#### Fitness Tracker (purpose='training')
| Method | Path | Parameters | Returns |
|---|---|---|---|
| POST | `/api/activities/upload` | Form: `file`, `activity_type`, `profile_id` | `{activity_id, gps_data, grade, flags}` |
| POST | `/api/activities/upload-batch` | Form: `files[]`, `activity_type`, `profile_id` | `{results: [...], total}` |
| GET | `/api/activities` | Query: `activity_type`, `profile_id` | `{activities: [...], count}` |
| GET | `/api/activities/{activity_id}` | — | `{activity, route_analysis}` |
| DELETE | `/api/activities/{activity_id}` | — | `{deleted: id}` |
| DELETE | `/api/activities` | Query: `profile_id` | `{deleted: "all training activities"}` |
| PATCH | `/api/activities/{activity_id}/name` | Body: `{custom_name}` | `{activity_id, custom_name}` |

#### RPS
| Method | Path | Parameters | Returns |
|---|---|---|---|
| POST | `/api/rps/calculate` | Query: `activity_type`, `profile_id` | Full RPS result (also saved as snapshot) |
| POST | `/api/rps/calculate-all-layers` | Query: `profile_id` | `{layer1: {road, trail, hike}, layer3_overall}` |
| GET | `/api/rps/snapshots` | Query: `activity_type`, `limit=20` | List of snapshot dicts |
| POST | `/api/rps/calculate-with-config` | Body: `{config: {...}}`, Query: `activity_type`, `profile_id` | RPS with overridden config (preview only, not saved) |

#### Calibration
| Method | Path | Parameters | Returns |
|---|---|---|---|
| GET | `/api/config` | — | `Config.to_dict()` output |
| POST | `/api/calibration/presets` | Query: `name`, `config` (dict) | `{preset_id}` |
| GET | `/api/calibration/presets` | — | List of presets |
| DELETE | `/api/calibration/presets/{preset_id}` | — | `{deleted: preset_id}` |

#### Export / Report
| Method | Path | Parameters | Returns |
|---|---|---|---|
| POST | `/api/export/activities` | — | Writes JSON to `exports/`, returns `{exported: path, count}` |
| POST | `/api/export/rps` | Query: `activity_type` | Writes JSON to `exports/`, returns `{exported: path, rps}` |
| GET | `/api/report/export` | — | Comprehensive AI-readable report JSON (see below) |

#### Health
| Method | Path | Returns |
|---|---|---|
| GET | `/api/health` | `{status, dem_available, db_path, db_exists}` |

---

**`/api/report/export` detail:** The most complex endpoint (~500 lines). For every profile computes: per-discipline RPS breakdowns, L1/L3 layer scores, per-activity detail (decay weights, component scores, gradient-normalised PC, TDS-adjusted SE, per-km gradients, TDS multiplier, flag diagnostics). Also computes full route_library (expanded climb details, terrain metrics) and race_readiness_assessments (profile × route cartesian product, matching activity types only). **Secrecy Rule:** formula values are omitted from the report; only variable names included for AI traceability. Returns as downloadable JSON attachment.

---


## 6. Frontend

### `App.jsx`
Root component. Manages global `profiles` and `activeProfileId` state. Fetches `/api/profiles` on mount; defaults to profile named "V". Nav bar with four `NavLink` items. React Router routes:
- `/` → `RouteAnalyzer`
- `/fitness` → `FitnessTracker`
- `/readiness` → `RaceReadiness`
- `/calibration` → `CalibrationPanel`

### `api.js`
Single `api` object. Base URL: `/api` (Vite-proxied to port 8000). Generic `request()` wrapper adds error handling and a specific message for "Backend not running". Methods map 1:1 to all endpoints.

### Views

**`RouteAnalyzer.jsx`**
- Upload triggers `api.uploadRoute(file, activityType)` directly (no confirm modal step).
- Displays: grade card (class badge, pillar breakdown, modifier source, TDS, effort descriptor), core metrics, elevation profile chart, terrain metrics grid, detected climbs list, Leaflet map, raw JSON collapsible.
- Inline rename via `InlineRename` → `api.renameActivity`.

**`FitnessTracker.jsx`**
- Three tabs: **RPS** (`RPSBreakdown` + decay table), **All Layers** (L1 grid + L3 card), **Activities** (table with rename, flags indicator).
- Multi-file upload via `api.uploadBatch()`.
- Profile switcher: click cards, inline rename, delete with confirm modal. "Backend not running" screen if fetch fails.

**`RaceReadiness.jsx`**
- Route selector + profile selector, Assess button → `api.getRaceReadiness(routeId, profileId)`.
- Verdict banner (colour-coded: READY=green, CLOSE=amber, NOT YET=red).
- Five `CheckCard` components with PASS/FAIL badge, progress bar, check-specific detail text.
- Performance Index check has expandable activity table showing all qualifying activities with their computed PI values.

**`CalibrationPanel.jsx`**
- On mount: `api.getConfig()` → populates `localConfig`.
- On any slider/input change: updates `localConfig`, debounces 500ms, calls `api.calculateRPSWithConfig(overrides, activityType, profileId)`.
- Overrides sent: `rps_weights`, `decay_half_life`, `rps_window_days`, `consistency_exponent`, `pc_climb_impact/saturation`, `pc_descent_impact/saturation`, `tds_bonus_rate`, `pc_gradient_ramp_ceiling`, `pc_gradient_ramp_power`.
- Reset restores server baseline. Export Report button triggers browser download of `RMM_Report_{timestamp}.json` via `api.exportReport()`.
- Left column: sliders (RPS weights, decay, window, consistency exponent, PC gradient params, TDS bonus rate); number inputs (benchmark ceilings); read-only reference cards (athlete levels, grade classes, elevation bands, modifier thresholds, TDS gain floors, PI grids).
- Right column: live `RPSBreakdown` preview.

### Shared Components

**`ui.jsx`:**
- `Card` — Dark surface container.
- `Stat` — Label + value + unit, 4 sizes.
- `ClassBadge` — Coloured badge per difficulty class. A=red, B=amber, C=blue, D=green, E=teal, F=sky.
- `LevelBadge` — Foundation=gray, Active=blue, Athlete=purple, Competitor=amber, Elite=red.
- `TagBadge` — Neutral badge for route type tags.
- `FlagBadge` — Coloured by severity.
- `ProgressBar`, `FileUpload` (GPX only), `Button` (4 variants × 3 sizes), `Select`, `Tabs`.
- `formatPace(secPerKm)` → `"M:SS"`.
- `formatDuration(totalSeconds)` → `"Xh Ym"` or `"Xm Ys"`.

**`RPSBreakdown.jsx`** — Headline score + `LevelBadge`, horizontal bar chart (Recharts) per component (distance=blue, speed_efficiency=purple, elevation=green, pace_consistency=amber, frequency=pink), component detail table, consistency modifier card, decay function card.

**`ElevationProfile.jsx`** — Recharts `AreaChart` (blue gradient fill) of `elevation` vs `distance_km`. Configurable height.

**`RouteMap.jsx`** — React-Leaflet map. `Polyline` from `coordinateStream`, `Marker` at start, auto-fits bounds. Leaflet default icon URLs patched for Vite.

**`InlineRename.jsx`** — Double-click or pencil icon to enter edit mode. Enter to confirm, Escape to cancel, blur to save. Calls `api.renameActivity()` or custom `onSave` prop (used for profile rename).

**`UploadConfirmModal.jsx`** — Preview modal with route metrics, activity type selector, surface tag (0–5), exposure tag (0–4). Defined but currently bypassed — `RouteAnalyzer` uploads directly on drop.

---


## 7. Testing

No test files anywhere in the codebase. No `pytest.ini`, `conftest.py`, test data files, CI configuration, Dockerfile, or `docker-compose.yml`. The README describes this as a "local proof-of-concept tool for stress-testing formula systems against real GPX data."

Validation approach is empirical: upload real GPX files, inspect outputs in the UI, export the AI report (`/api/report/export`), analyse the JSON externally.

---
