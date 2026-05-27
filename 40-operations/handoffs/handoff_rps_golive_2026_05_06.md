---
title: handoff_rps_golive_2026_05_06
domain: rmm
type: handoff
status: active
created: 2026-05-06
updated: 2026-05-06
updated_by: claude_opus_cowork
tags: [handoff, rps, milestone, strava, supabase, race-readiness]
supersedes: ""
related: ["[[handoff_engine_port_to_vercel]]", "[[handoff_supabase_production_schema]]", "[[website_build_status_issues]]"]
---
# Handoff — RPS Go-Live & Race Readiness Wiring (2026-05-06)

**Session type:** Milestone deployment
**Date:** 2026-05-06 (evening)
**Operator:** Claude Opus (Cowork) + Valken

---

## Milestone Achieved

**First live RPS score computed from real Strava data.**
Score: **28 / Active** — calculated from 27 synced Strava activities across three disciplines (Road: 25.67 from 23 activities, Trail: 27.52 from 1 activity, Hike: 21.07 from 3 activities).

This completes the Engine Build Sequence through Phase 3 (RPS) and partially wires Phase 4 (Race Readiness).

---

## What Was Done

### 1. RPS Formula Environment Variables Added to Vercel Production

All 33 RPS formula env vars were imported into Vercel Production via the bulk import tool. These cover distance, speed, elevation, pace consistency, and frequency component weights plus benchmark ceilings, exponential decay parameters, level thresholds, and the cross-discipline bonus percentage. A full redeployment was triggered afterward.

Source reference: `vercel-paste-ready.txt` in repo root contains all 93 env vars with values.

### 2. Supabase UUID-to-TEXT Column Type Fix (Critical)

**Problem:** The `activities` table was originally created (2026-04-25) with `athlete_id` as UUID type. The Strava sync code sends numeric Strava IDs as text strings (e.g., `"32748372"`), which PostgreSQL rejects with `22P02: invalid input syntax for type uuid`.

This single issue blocked both:
- Activity sync (all 27 INSERT operations failed)
- RPS calculation (SELECT on activities returned the same UUID cast error)

**Fix (run in Supabase SQL Editor):**
1. Dropped foreign key constraints: `activities_athlete_id_fkey` (activities → athletes.id)
2. Altered column types on three tables:
   - `ALTER TABLE activities ALTER COLUMN athlete_id TYPE TEXT`
   - `ALTER TABLE rps_scores ALTER COLUMN athlete_id TYPE TEXT`
   - `ALTER TABLE rps_history ALTER COLUMN athlete_id TYPE TEXT`
3. Ran `NOTIFY pgrst, 'reload schema'` to refresh PostgREST cache

**Impact:** The `athletes` table still uses UUID for its `id` column. The FK relationship between activities.athlete_id and athletes.id is now dropped. This is acceptable because athlete_id in activities stores the Strava numeric ID, not the internal athletes table UUID.

### 3. First Strava Activity Sync

After the UUID fix, Valken triggered a sync from the `/intelligence/fitness` page. 27 activities synced successfully covering a 90-day window. Activity type breakdown: 23 road, 1 trail, 3 hike. The high road count is because Strava classifies plain "Run" as road — most of these are actually Cape Peninsula mountain trails. This is a known calibration issue for future improvement (the `mapStravaType()` function in `api/auth/strava-activities.js` defaults "Run" to "road").

### 4. Cross-Discipline Bonus Bug Fix

**File:** `api/python/rps_engine.py` — line 372

**Problem:** Overall RPS showed 100 / Elite when individual discipline scores were 25–28. The `CROSS_DISCIPLINE_BONUS_PCT=5` env var (meaning 5%) was used as a raw multiplier: `bonus = weighted_avg * 5` ≈ 125, capped to 100.

**Fix:**
```python
# Old (broken):
bonus = weighted_avg * bonus_pct if len(active_disciplines) >= 2 else 0.0

# New (correct):
bonus = weighted_avg * (bonus_pct / 100.0) if len(active_disciplines) >= 2 else 0.0
```

Committed and pushed as part of this session. After fix, score correctly shows 28 / Active.

### 5. Race Readiness — Dynamic Route Selector

**Problem:** The readiness page had a hardcoded array of 7 GeoJSON route slugs (e.g., `"silvermine-lower-route-2"`). These are map display routes, not database entries. The backend looks up routes by database `id` in the `activities` table, so every selection returned 404/500.

**Fix (two files):**

**`api/python/race_readiness_check.py`** — Added "list mode": when `route_id` is omitted but `athlete_id` is present, the endpoint queries `route_analyses` + `activities` tables and returns a list of graded routes. This avoids needing a new serverless function (at 12/12 Hobby plan limit).

**`pages/intelligence-readiness.html`** — Replaced the hardcoded ROUTES array with a `loadGradedRoutes(athleteId)` function that fetches from the list mode endpoint. When no graded routes exist (current state), shows "No graded routes yet — upload a GPX on the Routes page".

**Status:** These files were edited locally. Need to be committed and pushed to deploy.

---

## Current State After This Session

| System | Status | Notes |
|---|---|---|
| Strava OAuth | LIVE | Login, token refresh, session management all working |
| Activity Sync | LIVE | 27 activities synced, GPS streams → GPX conversion working |
| GPS Stream Processor | LIVE | Used by sync and upload endpoints |
| Route Grading | LIVE | Drag-drop GPX upload, full grade display |
| RPS Engine | LIVE | First real score: 28/Active. All env vars set. |
| Race Readiness | WIRED | Backend + frontend connected, dynamic route selector. Needs graded routes to test against. |
| Anti-Gaming | DEPLOYED | Runs during authed uploads |

---

## Files Modified This Session

| File | Change | Committed? |
|---|---|---|
| `api/python/rps_engine.py` | Cross-discipline bonus ÷100 fix (line 372) | Yes — pushed to dev |
| `api/python/race_readiness_check.py` | Added list mode for graded routes | Needs commit + push |
| `pages/intelligence-readiness.html` | Dynamic route selector replacing hardcoded array | Needs commit + push |

---

## Known Issues Carried Forward

1. **Activity type classification:** 23/27 activities classified as "road" because Strava labels them "Run". The `mapStravaType()` function defaults to "road". Most are actually Cape Peninsula mountain trails. Future: consider terrain-based reclassification or user override.

2. **Race Readiness untestable:** No graded routes exist in the database yet. User needs to upload a GPX via `/intelligence/routes` to create a graded route, which will then appear in the readiness selector.

3. **Dropped FK constraint:** `activities_athlete_id_fkey` was dropped to allow the UUID→TEXT type change. The relationship between activities and athletes tables is now unlinked at the DB level. Acceptable for now but should be noted.

4. **Vercel 12/12 function limit:** At maximum serverless functions on Hobby plan. Any new endpoint requires consolidating existing ones or upgrading the plan.

---

## Related Notes

- [[handoff_engine_port_to_vercel]] — Previous session: engine deployment + env var setup
- [[handoff_supabase_production_schema]] — Original schema (had UUID types)
- [[website_build_status_issues]] — Updated with fixes from this session
