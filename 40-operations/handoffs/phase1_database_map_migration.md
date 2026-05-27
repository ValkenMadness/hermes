---
title: phase1_database_map_migration
domain: rmm
type: handoff
status: active
created: 2026-05-19
updated: 2026-05-19
updated_by: claude_cowork
tags: [handoff, trail-ecosystem, database, map, migration]
supersedes: ""
related: ["[[trail_ecosystem_build_phases]]", "[[trail_ecosystem_design]]", "[[website_architecture]]"]
---

# Phase 1 Handoff — Database Foundation + Map Migration

**Date:** 2026-05-19
**Status:** Code complete, awaiting deploy
**Next phase:** [[trail_ecosystem_build_phases#Phase 2 Admin Route Analyzer (Core)]]

---

## What Was Built

1. **Supabase migration SQL** (`supabase_migration_phase1.sql` in repo root)
   - PostGIS extension enabled
   - 5 tables: `trails`, `trail_segments`, `trail_pois`, `trail_poi_links`, `event_types`
   - RLS policies for public read of live content + service role full access
   - Event types seeded: trail, time_trial, hill_climb, hill_bomb

2. **New API endpoint** (`api/python/trails.py`)
   - GET `?action=list` → live trails as GeoJSON FeatureCollection
   - GET `?action=pois` → live POIs as GeoJSON FeatureCollection
   - GET `?action=event-types` → active event types
   - Seasonality filtering built in
   - Properties match what `map.js` popup expects: name, display_name, grade, grade_display, distance_km, elevation_gain_m, elevation_density

3. **Merged analyze.py into upload.py**
   - No `athlete_id` on multipart POST = public analyze (grade only, no DB write)
   - Response format identical to old `analyze.py`
   - `analyze.py` replaced with deprecation stub (must be `git rm`'d)
   - `vercel.json` rewrite: `/api/python/analyze` → `upload`

4. **Map migration** (`scripts/map.js`)
   - `RMM_ROUTES` array removed
   - `loadRMMRoutes()` fetches from `/api/python/trails?action=list`
   - Empty response handled gracefully (sources/layers created but empty)
   - All downstream code unchanged: layers, clusters, popups, pulse, highlights

5. **Vercel routing** (`vercel.json`)
   - `/api/python/analyze` → `upload` (backward compat)
   - `/api/python/trails` → `trails`
   - `/api/python/pois` → `trails`

---

## Before You Deploy

1. Run `supabase_migration_phase1.sql` in Supabase SQL Editor
2. `git rm api/python/analyze.py`
3. `git rm public/data/routes/*.geojson` (all 8 files)
4. `git rm public/data/routes/DELETE_THESE_FILES.md`
5. Optionally delete `supabase_migration_phase1.sql` from repo root after running it
6. Commit and push to main → Vercel auto-deploys

---

## Test Checklist

- [ ] Map loads with empty trails table — no errors, no blank screen
- [ ] Peaks and caves still render normally
- [ ] Filter sidebar routes toggle works (even when empty)
- [ ] Public Route Analyzer at `/intelligence/route-grading` still works
- [ ] Insert a test trail manually into `trails` table with `status='live'` and `coordinates_json` populated — verify it appears on map
- [ ] API returns empty GeoJSON: `curl https://runmadmaps.com/api/python/trails?action=list`

---

## Key Decisions

- **coordinates_json over PostGIS for API reads:** The `coordinates_json` JSONB column is the primary data source for API responses. The PostGIS `geometry` column exists for future spatial queries but isn't used in the REST layer yet.
- **Public analyze detection:** Uses absence of `athlete_id` field, not session cookie. Matches existing frontend pattern.
- **analyze.py stub:** Can't delete files from Cowork — replaced with 410 Gone stub. Must be git rm'd manually.

---

## Files Changed

| Action | File |
|---|---|
| CREATE | `supabase_migration_phase1.sql` |
| CREATE | `api/python/trails.py` |
| MODIFY | `api/python/upload.py` (absorbs public analyze) |
| REPLACE | `api/python/analyze.py` (deprecation stub — delete this) |
| MODIFY | `scripts/map.js` (API-driven route loading) |
| MODIFY | `vercel.json` (new rewrites) |
| CREATE | `public/data/routes/DELETE_THESE_FILES.md` (cleanup marker) |
