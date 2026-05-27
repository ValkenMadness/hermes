---
title: formula_lab_build_status_issues
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: claude_code
tags: [codebase, formula-lab, bugs, technical-debt]
supersedes: ""
related: ["[[formula_lab_build_status_overview]]", "[[formula_lab_architecture_overview]]"]
---

# Formula Lab — Build Status: Known Issues

Audit date: 2026-04-23. Based on direct code inspection of all Python and JSX files.

---

## 4. Known Bugs and Code Issues

### `race_readiness.py` — `multiplier_used` missing from response
`RaceReadiness.jsx` renders `{check.multiplier_used}` in the Volume Load card and Elevation Coverage card. Neither `_check_volume_load` nor `_check_elevation_coverage` includes a `multiplier_used` key in their returned dicts. Both UI fields render as blank/undefined. The fix is to add `"multiplier_used": multiplier` to those two return dicts.

### `anti_gaming.py` — `datetime` imported inside loops
`anti_gaming.py`'s module-level imports are only `math`, `Config`, and `haversine`. The `datetime` class is imported inside `_check_f2` and `_check_f3` on every iteration over `all_activities`. Python caches module imports so this does not crash, but it is poor practice and will trigger lint warnings.

### `app.py` — `export_activities` and `export_rps` ignore profile
Both `/api/export/activities` (line 594) and `/api/export/rps` (line 617) call `db.get_all_activities(purpose="training")` with no `profile_id` filter. They export and compute across all profiles' data combined. A user on a specific profile who exports would get the entire database's training data, not their profile's. The `/api/report/export` endpoint correctly segments by profile.

### `app.py` — raw_data mutation in `calculate_rps` endpoint
Lines 493–498 directly mutate the dict from `a["raw_data"]` by adding `activity_type`, `date`, and `id` keys. This mutates the object in-place rather than copying it. The `/api/report/export` endpoint correctly uses `data = {**a["raw_data"]}` (a shallow copy). The RPS endpoint should do the same.

### `app.py` — no UTF-8 decode error handling on GPX upload
```python
gpx_text = content.decode("utf-8")
```
GPS files from some devices use UTF-16 or Latin-1 encoding. A non-UTF-8 file raises an unhandled `UnicodeDecodeError`, returning a 500 to the client instead of a descriptive 400. Should be wrapped in `try/except UnicodeDecodeError`.

### `database.py` — connections not closed on exception
All database functions open a connection, operate, and call `conn.close()` at the end. If an exception occurs mid-function, the `close()` is skipped. In a long-running FastAPI process this can accumulate open file handles. Should use `try/finally` or context managers (`with sqlite3.connect(...) as conn:`).

### `CalibrationPanel.jsx` — `console.error` left in production
Line 90 in `CalibrationPanel.jsx` has `console.error(e)` inside the `recalculate()` catch block. This logs to the browser console on any failed recalculation. Not a functional bug but should be removed or replaced with UI error state.

### `app.py` — `RouteTypeUpdate` model defined after use
`RouteTypeUpdate` class is defined at line 310 but used as a type annotation in `update_route_type` at line 258. This works at runtime (FastAPI resolves annotations lazily), but is an unconventional ordering.

### `RPSBreakdown.jsx` — genuine RPS=0 shows empty state
Line 22: `if (!rps || rps.rps === 0)` shows "No activity data" for both the null case and a genuine score of zero. An athlete who has uploaded activities but scores exactly 0.00 would see a blank breakdown instead of components. Minor edge case.

---


## 7. Hardcoded Values That Should Be in Env Vars

The following numeric constants are used directly in computation functions with no corresponding `Config` attribute or `.env` variable. They are formula values that affect outputs and could legitimately need tuning.

| File | Line | Value | Role | Impact |
|---|---|---|---|---|
| `gps_processor.py` | 666 | `50` | TBS elevation density normalisation ceiling (m/km) | Controls when ED component of TBS saturates at 100 |
| `gps_processor.py` | 667 | `30` | TBS max gradient normalisation ceiling (%) | Controls when gradient component of TBS saturates |
| `gps_processor.py` | 668 | `15` | TBS gradient variability normalisation ceiling (%) | Controls when variability component of TBS saturates |
| `gps_processor.py` | 695 | `10` | RCS climb count normalisation ceiling | Controls when climb count component of RCS saturates |
| `gps_processor.py` | 696 | `3` | RCS effort index normalisation ceiling | Controls when effort index component saturates |
| `gps_processor.py` | 697 | `120` | RCS split deviation normalisation ceiling (seconds) | Controls when split deviation component saturates |
| `gps_processor.py` | 134–137 | `300` | Effort index baseline pace (sec/km) | Explicitly labelled placeholder; feeds directly into RCS |
| `gps_processor.py` | 716 | `0.0002` | F9 grid cell size (degrees, ≈20m at Cape Town latitude) | Grid resolution for coordinate revisit detection; latitude-sensitive |
| `race_readiness.py` | 50–58 | `10, 25, 50, 100` | Race readiness distance band thresholds (km) | Band boundaries that must stay in sync with band-keyed config dicts |

**Lower priority (API/UI constants, not formula values):**

| File | Line | Value | Role |
|---|---|---|---|
| `gps_processor.py` | 166 | `500` | Elevation profile chart sample limit |
| `gps_processor.py` | 170 | `1000` | Coordinate stream API response cap |
| `gps_processor.py` | 520 | `200` | Gradient segments API response cap |

The six TBS/RCS normalisation ceilings are the most important gap. They directly determine how TBS and RCS convert to 0–100 scores. The TBS score feeds into TDS and difficulty class. These values have never been tunable without editing source code.

---


## 8. TODO / FIXME Comments

**Zero formal TODO/FIXME/HACK/XXX comments exist anywhere in the codebase.** Grep returns no matches across all `.py` and `.jsx` files for any of these keywords.

Incomplete work is noted via English-language inline comments only:

| File | Line | Comment | Status |
|---|---|---|---|
| `gps_processor.py` | 136 | `"5:00 flat pace baseline placeholder"` | Active placeholder — `300` sec/km is never replaced |
| `anti_gaming.py` | 181 | `"Placeholder — needs full GPS coord access"` | F4 is a permanent stub; this comment is the only indicator |
| `anti_gaming.py` | 179 | `"Real implementation would check lat/lon variance"` | Describes what F4 should do but doesn't do |
| `app.py` | 1004 | `"active": False, "note": "placeholder — pending implementation"` | Report export marks F4 inactive; must be updated if F4 is ever implemented |

No formal tracking of incomplete work exists. Incomplete items are discoverable only by code reading.
