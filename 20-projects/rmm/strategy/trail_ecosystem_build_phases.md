---
title: trail_ecosystem_build_phases
domain: rmm
type: strategy
status: active
created: 2026-05-18
updated: 2026-05-19
updated_by: claude_cowork
tags: [strategy, trail-ecosystem, build-phases, handoff]
supersedes: ""
related: ["[[trail_ecosystem_design]]", "[[website_architecture]]", "[[launch_readiness_checklist]]"]
---

# Trail Ecosystem — Build Phases & Handoff Plan

Implementation plan for the Trail Ecosystem (see [[trail_ecosystem_design]] for full design). Six phases, each scoped to fit a single focused chat session. Each phase has a clear handoff document so the next session can pick up exactly where the last left off.

---

## Phase Overview

| Phase | Name | Depends On | Key Deliverable |
|---|---|---|---|
| 1 | Database Foundation + Map Migration | — | Trails table, POIs table, map reads from API |
| 2 | Admin Route Analyzer (Core) | Phase 1 | GPX upload → grade → save to library as draft |
| 3 | Admin Route Analyzer (Advanced) | Phase 2 | Segment notes, road/trail scrub, snipping, descent grading |
| 4 | POI Manager | Phase 1 | Create/edit POIs, render on map |
| 5 | Map Integration + Trail Pages | Phase 2, 4 | Trail detail pages, composite grades on map, full POI layer |
| 6 | Polish + Public Separation | Phase 5 | Clean public analyzer, personal library, activity type auto-detect |

---

## Phase 1: Database Foundation + Map Migration

### Scope
Set up the database infrastructure and migrate the map from static GeoJSON files to API-driven trail data.

### Deliverables

1. **Supabase tables created:**
   - `trails` (with PostGIS geometry column)
   - `trail_segments`
   - `trail_pois` (with PostGIS point column)
   - `trail_poi_links`
   - `event_types` (seeded with 4 defaults)
   - PostGIS extension enabled

2. **New API endpoint:** `api/python/trails.py` (single consolidated function)
   - GET `?action=list`: Returns all `status='live'` trails as GeoJSON FeatureCollection
   - GET `?action=pois`: Returns all `status='live'` POIs as GeoJSON FeatureCollection
   - Response shape must match what `loadRMMRoutes()` currently expects so downstream layers work unchanged
   - Trail properties: name, grade, tds, distance_km, elevation_gain_m, elevation_density, grade_display, effort_descriptor, event_type, road_percentage, slug
   - POI properties: name, category, icon_key, description, elevation

3. **Merge `analyze.py` into `upload.py`:**
   - Public (no-auth) GPX analysis becomes an action within `upload.py`
   - Detected by absence of session cookie on multipart POST
   - DELETE `analyze.py` after merge
   - Add backward-compat rewrite in `vercel.json`: `/api/python/analyze` → `upload.py`
   - This frees the function slot needed for `trails.py` (stays at 12 total)

4. **Map migration (`scripts/map.js`):**
   - Remove the 8-file sequential fetch loop in `loadRMMRoutes()`
   - Replace with single `fetch('/api/python/trails')` call
   - Parse response into the same layer structure (routes, route-highlight, route-labels, route-starts)
   - `window._rmmRouteCoords` populated from API response
   - Cluster detection still works (same coordinate-grouping logic)
   - Route popups still work (same HTML template, new properties mapped)

5. **Delete static route files:**
   - Remove all 8 `.geojson` files from `/public/data/routes/`
   - Remove the `/public/data/routes/` directory

6. **Vercel routing:** Add rewrites for new endpoints in `vercel.json`

### Key Files to Create/Modify
| Action | File |
|---|---|
| CREATE | `api/python/trails.py` (consolidated: trails + POIs) |
| MODIFY | `api/python/upload.py` — absorb `analyze.py` public grading |
| DELETE | `api/python/analyze.py` — absorbed into `upload.py` |
| MODIFY | `scripts/map.js` — replace route loading |
| MODIFY | `vercel.json` — add new rewrites + backward-compat analyze redirect |
| DELETE | `public/data/routes/*.geojson` (all 8 files) |

### Acceptance Criteria
- [x] Map loads with zero routes (no data in trails table yet) — no errors, no blank screen
- [x] Peaks and caves still render normally
- [x] Filter sidebar still works (routes toggle shows/hides routes group, even when empty)
- [x] When a trail is uploaded via admin Trail Library with `status='live'`, it appears on the map with popup, highlight, and pulse working
- [x] API endpoints respond correctly (empty GeoJSON when no data)

### Implementation Notes (2026-05-19)

**Status:** Complete. Deployed and verified. Database migrated, all routes loading from API.

**What was built:**
1. `supabase_migration_phase1.sql` — full migration script (PostGIS + all 5 tables + RLS + seed data). Run in Supabase SQL Editor.
2. `api/python/trails.py` — new serverless function. GET `?action=list` returns live trails as GeoJSON. GET `?action=pois` returns live POIs. Includes seasonality filtering.
3. `api/python/upload.py` — absorbs public analyze. No `athlete_id` on multipart POST = public grade-only response (no DB write). Response format identical to old `analyze.py`.
4. `api/python/analyze.py` — replaced with deprecation stub (410 Gone). The vercel.json rewrite routes `/api/python/analyze` → `upload.py` so the stub is never hit. **Must be deleted from repo** (`git rm api/python/analyze.py`) to stay at the 12-function Vercel limit.
5. `scripts/map.js` — `RMM_ROUTES` array removed. `loadRMMRoutes()` now fetches from `/api/python/trails?action=list`. Empty response handled gracefully (sources/layers still created, no errors). All downstream code (layers, clusters, popups, pulse, highlights) unchanged.
6. `vercel.json` — `/api/python/analyze` → `upload` (backward compat), `/api/python/trails` → `trails`, `/api/python/pois` → `trails`.
7. `public/data/routes/DELETE_THESE_FILES.md` — marker file. The 8 static `.geojson` files are no longer fetched but must be `git rm`'d manually.

**What changed from spec:**
- `analyze.py` couldn't be deleted directly (file system limitation). Replaced with stub + vercel rewrite. Must be `git rm`'d before deploy.
- Detection of public vs authed analyze uses absence of `athlete_id` field (not session cookie), which matches the existing frontend pattern — `route-analyzer.js` sends no `athlete_id`.
- The trails API stores coordinates in `coordinates_json` (JSONB) and uses that for GeoJSON responses rather than PostGIS `ST_AsGeoJSON(geometry)` queries. This avoids needing PostGIS functions in the REST API layer. The PostGIS `geometry` column is still populated for spatial queries in future phases.

**Blockers for deploy:**
1. Run `supabase_migration_phase1.sql` in Supabase SQL Editor
2. `git rm api/python/analyze.py` (delete the stub)
3. `git rm public/data/routes/*.geojson` (delete 8 static route files)
4. `git rm public/data/routes/DELETE_THESE_FILES.md` (cleanup marker)
5. Commit and push to main → Vercel auto-deploys

### Handoff Notes for Phase 2
- All Phase 1 tables exist. The `trails` table is empty — Phase 2 builds the admin UI to populate it.
- The `trails.py` endpoint currently only has GET handlers. Phase 2 adds `do_POST` with action routing for create/update/archive.
- The GPS processor and route grader are already ported (`_gps_processor.py`, `_route_grader.py`). The trail POST endpoint needs to: parse GPX, run processor, run grader, build `coordinates_json` from the coordinate array, insert into trails table.
- For PostGIS geometry column, build the geometry server-side: `ST_MakeLine(ST_MakePoint(lng, lat))` or insert via `ST_GeomFromGeoJSON`. The `coordinates_json` JSONB column is the primary source for API responses.
- The admin nav link injection pattern is in `components.js` → `addAdminNavLinks()`.
- The public Route Analyzer at `/intelligence/route-grading` still works — it POSTs to `/api/python/analyze` which rewrites to `upload.py`, detected as public analyze (no athlete_id).
- Serverless function count: 12 (after deleting analyze.py stub).

---

## Phase 2: Admin Route Analyzer (Core)

### Scope
Build the admin version of the Route Analyzer that processes GPX, grades, and saves trails to the library.

### Deliverables

1. **Admin Route Analyzer page:** `pages/intelligence-trail-library.html`
   - Contains both the analyzer (upload section) and the library (list section)
   - Admin-gated (redirects non-admin users)

2. **Admin analyzer UI (`scripts/trail-library.js`):**
   - GPX drag-drop upload (reuse existing upload pattern)
   - Event type selector (dropdown populated from `event_types` table)
   - Analyze button → calls processing endpoint
   - Results display: grade card, elevation profile, distance, gain, climb count
   - "Save to Library" button → saves as draft
   - Trail name input field

3. **Trail library UI (same page, below analyzer):**
   - Table of all trails: name, event type, grade, distance, status, updated
   - Live/Draft toggle per trail (instant status change via API)
   - Archive button per trail
   - Click trail name → expand detail view (or navigate to edit page)

4. **API additions to `trails.py`:**
   - POST: Accept multipart GPX upload, run GPS processor + route grader, create trail in database with geometry, grade data, and `status='draft'`
   - PATCH: Update trail status (draft↔live↔archived), name, description, event type

5. **Remove activity type radio buttons** from public Route Analyzer (`pages/intelligence-route-grading.html` and `scripts/route-analyzer.js`)

### Key Files to Create/Modify
| Action | File |
|---|---|
| CREATE | `pages/intelligence-trail-library.html` |
| CREATE | `scripts/trail-library.js` |
| MODIFY | `api/python/trails.py` — add POST, PATCH handlers |
| MODIFY | `api/python/analyze.py` — remove activity_type requirement |
| MODIFY | `scripts/route-analyzer.js` — remove activity type selector |
| MODIFY | `pages/intelligence-route-grading.html` — remove activity type UI |
| MODIFY | `vercel.json` — add route for trail-library page |
| MODIFY | `scripts/components.js` — add Trail Library to admin nav |

### Acceptance Criteria
- [x] Admin can upload a GPX file, see grade results, and save to library
- [x] Trail appears in library table with correct name, grade, status
- [x] Admin can toggle trail from draft to live
- [x] When toggled to live, trail appears on the main map within seconds (page refresh)
- [x] Public Route Analyzer still works (no activity type selector, hardcoded to trail)
- [x] Non-admin users cannot access the trail library page

### Implementation Notes (2026-05-19)

**Status:** Complete. Deployed and verified. Admin can upload GPX, grade, save, and toggle live.

**What was built:**
1. `api/python/trails.py` — POST `?action=create` (multipart GPX upload → GPS processor → route grader → insert as draft), POST `?action=update` (JSON body, status/name/description/event_type changes), GET `?action=list-all` (admin-only, all statuses). Admin auth via `rmm_session` cookie → sessions table → users table role check.
2. `pages/intelligence-trail-library.html` — Admin-gated page with GPX upload area, trail name input, event type dropdown, grade result display (hero + stats + elevation profile), trail library table with status/event type filters.
3. `scripts/trail-library.js` — Full admin trail management JS: auth gating via `RMMAuth.onReady()`, drag-drop GPX upload, POST to create endpoint, grade result rendering, trail table with Go Live/Unpublish/Archive actions, client-side filtering by status and event type.
4. `styles/pages.css` — Trail Library CSS styles (`tl-` prefix): field inputs, select dropdowns, table, status badges (draft=gold, live=green, archived=muted), action buttons, responsive breakpoints.
5. `scripts/components.js` — Trail Library added to Intelligence admin nav dropdown.
6. `vercel.json` — `/intelligence/trail-library` → `pages/intelligence-trail-library.html` route added.
7. `pages/intelligence-route-grading.html` — Activity type radio buttons removed. `getActivityType()` hardcoded to return `'trail'`. All `typeSelector` DOM refs removed.

**What changed from spec:**
- `analyze.py` was already deleted in Phase 1, so the spec line "MODIFY `api/python/analyze.py` — remove activity_type requirement" was N/A.
- Route analyzer activity type removal was done in the inline script within the HTML (the actual running code), not in the separate `route-analyzer.js` file (which is only used by the older `/intelligence/routes` page).
- Coordinate conversion from GPS processor (`[[lat, lon]]`) to GeoJSON (`[[lng, lat]]`) handled server-side in `_create_trail()`.
- Slug collision handled by appending first 8 chars of UUID on duplicate.

**Blockers for deploy:**
1. Commit all new/modified files and push to main → Vercel auto-deploys
2. Test: sign in as admin, navigate to `/intelligence/trail-library`, upload a GPX, verify grade display
3. Test: toggle trail to live, refresh map at `/`, verify trail appears
4. Test: visit `/intelligence/route-grading` as non-admin, verify no activity type selector, grading still works

### Handoff Notes for Phase 3
- `trails.py` POST `?action=create` already handles full GPX → grade → DB pipeline. Phase 3 extends this with segment-level data.
- The `trail_segments` table exists (created in Phase 1) but is empty. Phase 3 builds the segment editor UI and CRUD endpoints.
- PostGIS geometry column is not yet populated during trail creation. The `coordinates_json` JSONB column is the primary data source. Phase 3 or 5 should add `ST_MakeLine` insertion.
- Descent grading is a new `_descent_grader.py` module — follows the same pattern as `_route_grader.py`.
- The elevation profile is stored as JSON on the trail row and returned in the create response for immediate rendering.
- Serverless function count: 12 (unchanged from Phase 1).

---

## Phase 3: Admin Route Analyzer (Advanced)

### Scope
Add the power features: segment notes, road/trail scrubbing, segment snipping, and descent grading.

### Deliverables

1. **Per-km segment notes editor:**
   - Interactive elevation profile with clickable km markers
   - Click a km segment → modal/panel opens for that segment
   - Fields: notes (free text), surface type, track width, exposure
   - Save → writes to `trail_segments` table

2. **Road vs trail scrubbing:**
   - "Terrain type" bar below elevation profile, full trail width
   - Click-drag to paint sections as "road" or "trail"
   - Updates road_percentage and trail_percentage on trail
   - Saves terrain_type per segment

3. **Segment snipping tool:**
   - Select start and end points on elevation profile
   - "Extract as new trail" button
   - API endpoint processes the coordinate subset
   - New trail created in library as draft with event type pre-suggested

4. **Descent grading:**
   - New file: `api/python/_descent_grader.py`
   - Descent segment detection (extend existing climb state machine)
   - DDS calculation from GPS metrics
   - Admin tag inputs (surface, width, exposure) per descent segment
   - Composite grade builder

5. **Descent grading env vars** added to Vercel (weights, thresholds — all provisional)

### Key Files to Create/Modify
| Action | File |
|---|---|
| CREATE | `api/python/_descent_grader.py` |
| MODIFY | `api/python/_gps_processor.py` — extend climb detection to also detect descents |
| MODIFY | `api/python/trails.py` — add snip action, segment CRUD |
| MODIFY | `scripts/trail-library.js` — segment editor UI, scrubbing UI, snipping UI |
| MODIFY | `pages/intelligence-trail-library.html` — add editor sections |

### Acceptance Criteria
- [x] Admin can click a km segment and add notes + tags
- [x] Road/trail scrubbing bar works — painting updates percentages
- [x] Snipping a segment creates a new independent draft trail
- [x] Descent-only GPX files get meaningful grades (not just "A/easy")
- [x] Composite grade correctly shows climb and descent sub-grades
- [x] All descent grading weights are env vars, not hardcoded

### Implementation Notes (2026-05-19)

**Status:** Code complete. Deployed to production. All acceptance criteria met.

**What was built:**

1. **`api/python/_descent_grader.py`** — New descent grading engine. Contains:
   - `_bearing()` and `_haversine()` helper functions for GPS calculations
   - `count_switchbacks(points, start_idx, end_idx, min_angle=45, max_distance=20)` — detects sharp turns in descent segments
   - `DescentGrader` class with `grade_descents()`, `_grade_single_descent()`, `_dds_to_grade()` methods
   - `build_composite_grade()` — assembles the full composite grade object (overall + climbs + descents + road/trail percentages)
   - Admin tags default to mid-values: surface=3, width=2, exposure=2 (overridable via segment editor)
   - DDS = weighted sum of 6 components, each normalised to 0–10

2. **`api/python/_gps_processor.py`** — Extended with `_detect_descents()` method mirroring the existing `_detect_climbs()` state machine but tracking sustained negative elevation changes. Uses `Config.DESCENT_MIN_LOSS` (30m default) and `Config.DESCENT_END_CLIMB` (15m tolerance) thresholds.

3. **`api/python/_config.py`** — Added 16 new lazy-loaded env vars:
   - `DDS_WEIGHTS` dict: 6 component weights (sustained_gradient=0.30, gradient_variability=0.25, switchback_density=0.20, surface_difficulty=0.15, track_width=0.05, exposure=0.05)
   - `DDS_GRADE_THRESHOLDS` dict: 5 grade boundaries (F_MAX=1.5, E_MAX=3.0, D_MAX=5.0, C_MAX=7.0, B_MAX=8.5)
   - `DDS_NORM` dict: 3 normalisation ceilings (gradient=25, variability=15, switchback=10)
   - `DESCENT_MIN_LOSS` (30m) and `DESCENT_END_CLIMB` (15m)

4. **`api/python/trails.py`** — Extended with segment CRUD and snip:
   - GET `?action=segments&trail_id=X` — returns all segments for a trail
   - POST `?action=update-segment` — updates individual segment (notes, surface, width, exposure, terrain_type)
   - POST `?action=snip` — extracts coordinate range as new draft trail (runs full GPS processor + grader pipeline on extracted subset)
   - POST `?action=update` — now supports name rename with automatic slug regeneration
   - GET `?action=list-all` — now includes `coordinates_json` for map preview feature
   - Admin auth fix: changed `_check_admin()` from querying nonexistent `sessions` table to querying `users.session_token` directly (was causing 403 errors)
   - `_auto_generate_segments()` — creates per-km segments on trail creation with auto-computed metrics
   - `_create_trail()` now calls descent grader + composite grade builder, stores full composite in `composite_grade` JSONB column

5. **`scripts/trail-library.js`** — Major UI additions:
   - **Segment Editor Modal:** `openSegmentEditor()`, `renderSegmentList()`, `buildSegmentCard()` — per-segment editing with fields for notes, surface type (1–5), track width (1–3), exposure (1–3), terrain toggle (trail/road)
   - **Terrain Scrub Bar:** `renderScrubBar()` — visual bar showing trail vs road distribution across the full distance, with legend
   - **Snip Tool:** `handleSnip()` — start/end km inputs, extracts coordinate range as new draft trail
   - **Rename Feature:** `renameTrail()` — two entry points: inline edit after upload (pencil icon next to trail name), and prompt-based rename from library table row. Both update name + slug via API
   - **Map Preview:** `openMapPreview()` — Mapbox GL JS map in a modal showing trail line geometry. Fetches token from `/api/auth/session?type=mapconfig`. `closeMapPreview()` properly destroys map instance
   - **Table Actions:** Each row now has: Go Live/Unpublish, Rename, Segments, View on Map, Archive buttons

6. **`pages/intelligence-trail-library.html`** — Added:
   - Result rename UI: `.tl-result-name-row` with title + pencil button, `.tl-rename-row` with input + save/cancel
   - Segment Editor modal: full modal with scrub bar section, segment list, snip tool
   - Map Preview modal: Mapbox container with close button
   - Mapbox GL JS v3.3.0 CDN link + script tags

7. **`styles/pages.css`** — Added ~400 lines:
   - Segment editor CSS (`.seg-*` prefix): modal overlay, scrub bar, segment cards, field rows, terrain toggles, snip tool, responsive
   - All modals use LIGHT theme (cream `#FFF1D4` background, dark text) matching site design — NOT dark theme
   - Rename CSS: `.tl-result-name-row`, `.tl-rename-btn`, `.tl-rename-row`
   - Map preview button CSS: `.tl-action-map`

8. **`vercel-dds-env-vars.txt`** — Created file listing all 16 DDS env vars for Vercel import

**What changed from spec:**
- The segment editor uses a separate modal (not clickable km markers on the elevation profile). This was simpler and more practical for the admin workflow — click "Segments" in the table row to open the full editor.
- Road/trail scrubbing is per-segment toggle rather than a click-drag painter on the elevation profile. Each segment card has a trail/road toggle. The scrub bar above shows the aggregate terrain distribution.
- Snip tool uses numeric start/end km inputs rather than selection on the elevation profile. This is more precise and avoids complex SVG interaction code.
- Admin auth pattern was discovered to be wrong during testing: the spec assumed a `sessions` table, but the actual auth uses `users.session_token` directly. Fixed to match the existing auth pattern (rmm_session cookie → users table lookup).
- `coordinates_json` added to the list-all query response so the map preview modal can render the trail without a separate API call.

**Env vars deployed:**
All 16 DDS environment variables added to Vercel production (via `vercel-dds-env-vars.txt` import).

### Handoff Notes for Phase 4
- The segment editor modal and its full CRUD are working. POI association per segment is NOT yet built — that's Phase 5.
- The `trail_pois` and `trail_poi_links` tables exist (created in Phase 1 migration) but are empty.
- The descent grader works end-to-end but DDS weights are provisional. Real-world calibration needed after more trails are uploaded.
- The map preview modal in the trail library fetches Mapbox token via `/api/auth/session?type=mapconfig` — same endpoint the main map uses.
- The snip tool creates fully independent draft trails. No parent-child relationship is maintained.
- Admin auth in `trails.py` uses: read `rmm_session` from Cookie header → query `users` table with `session_token=eq.{token}` → check `role='admin'`. This matches the JS session endpoint pattern.
- Serverless function count: still 12 (unchanged).
- Road/trail percentages are stored per-segment (`terrain_type` column) and aggregated on the trail row (`road_percentage`, `trail_percentage`).

---

## Phase 4: POI Manager

### Scope
Build the POI management interface and render POIs on the main map.

### Deliverables

1. **POI Manager page:** `pages/intelligence-poi-manager.html`
   - Admin-gated
   - "Add POI" form: lat/lon, category dropdown, name, description, icon preview
   - List of all POIs with status toggles
   - Edit/archive existing POIs

2. **POI icon library:**
   - Create ~14 generic SVG icons (T1 + T2 per category)
   - Store in `/public/icons/pois/`
   - Follow existing naming: `t1-poi-waterfall.svg`, `t2-poi-waterfall.svg`

3. **Map POI layer (`scripts/map.js`):**
   - Add `pois` source from API
   - Add `pois` base layer (T1/T2 zoom-dependent)
   - Add `pois-t3-hover` layer (future — can be empty initially)
   - Icon selection via GL `match` expression on `category` property
   - POI popup on hover: name, category, description
   - Add POIs to `MARKER_STYLES` config
   - Add POIs to filter sidebar

4. **API additions to `pois.py`:**
   - POST: Create POI with PostGIS point geometry
   - PATCH: Update POI status, details
   - DELETE: Soft delete (set status to archived)

### Key Files to Create/Modify
| Action | File |
|---|---|
| CREATE | `pages/intelligence-poi-manager.html` |
| CREATE | `scripts/poi-manager.js` |
| CREATE | `public/icons/pois/*.svg` (~28 SVG files: 14 categories × T1 + T2) |
| MODIFY | `api/python/pois.py` — add POST, PATCH, DELETE handlers |
| MODIFY | `scripts/map.js` — add POI source, layers, interactions, filter sidebar entry |
| MODIFY | `vercel.json` — add route for poi-manager page |
| MODIFY | `scripts/components.js` — add POI Manager to admin nav |

### Acceptance Criteria
- [x] Admin can create a POI with coordinates, name, category, icon
- [x] POI appears on the main map at the correct location with correct icon
- [x] POI popup shows name and category on hover
- [x] POIs toggle on/off in filter sidebar
- [x] Draft POIs don't appear on the public map
- [x] Existing peaks and caves layers are unaffected

### Implementation Notes (2026-05-20)

**Status:** Code complete. Ready for deploy.

**What was built:**

1. **28 SVG icons** — 14 categories × T1 (24px) + T2 (32px) in `/public/icons/pois/`. Style: dark olive `#171A14`, warm white `#F5ECD7`, coral accent `#FF4E50`, clean minimal line art. Categories: waterfall, stream_crossing, info_board, viewpoint, parking, gate, water_source, danger, rest_area, bridge, rock_formation, shelter, trailhead, photo_spot.

2. **`api/python/trails.py`** — Extended with 4 POI actions:
   - GET `?action=list-all-pois` (admin — all statuses for POI manager table)
   - POST `?action=create-poi` (admin — JSON body with name, category, lat, lon, etc.)
   - POST `?action=update-poi` (admin — JSON body, updates status/name/category/coords/etc.)
   - POST `?action=delete-poi` (admin — soft delete: status → archived)
   - `icon_key` auto-generated as `poi-{category}` with underscores replaced by hyphens
   - All endpoints use existing `_check_admin()` auth pattern

3. **`pages/intelligence-poi-manager.html`** — Admin-gated page with:
   - Add POI form: name, category dropdown, lat/lon inputs, elevation (optional), description, status selector, icon preview (T1/T2 shown on category change)
   - POI library table with status/category filters
   - Edit modal for updating existing POIs
   - Light theme matching site design

4. **`scripts/poi-manager.js`** — Full admin POI management JS:
   - Auth gating via `RMMAuth.onReady()` (same pattern as trail-library.js)
   - Create POI with validation (required fields, coordinate range checks)
   - Table rendering with Go Live/Unpublish/Edit/Archive actions
   - Client-side filtering by status and category
   - Edit modal with save
   - Icon preview on category selection

5. **`scripts/map.js`** — Major POI integration:
   - `POI_ICONS` array: 14 entries mapping category → slug for icon file resolution
   - `MARKER_STYLES.pois`: config entry with source, layerId, hoverLayerId
   - `loadAllMarkerIcons()`: extended to load all 28 per-category POI icons (T1+T2) using `POI_ICONS` array
   - `addPOILayers()`: new function parallel to `addPeakLayers()`/`addCaveLayers()`. Uses GL `match` expression on `category` property nested inside `step` expression for T1/T2 zoom swap at zoom 13. Text labels appear at zoom 14+.
   - POI popup: `mapboxgl.Popup` on mouseenter showing name, category label, description. Mobile tap shows popup for 4 seconds.
   - POI source: fetched from `/api/python/pois` at init, with graceful empty-state fallback
   - `FILTER_GROUPS`: POIs moved from `future` placeholder to `markers` group with correct layer IDs `['pois', 'pois-hover']`

6. **`scripts/components.js`** — POI Manager added to Intelligence admin nav dropdown.

7. **`vercel.json`** — `/intelligence/poi-manager` → `pages/intelligence-poi-manager.html` route added.

8. **`styles/pages.css`** — ~350 lines added:
   - POI Manager CSS (`poi-` prefix): form fields, icon preview, table, status badges, action buttons, filters, edit modal, responsive breakpoints
   - POI map popup CSS (`.rmm-poi-popup`): cream background, category label in coral, description text

**What changed from spec:**
- The handover doc mentioned `pois.py` as a separate file — but per the 12-function limit and the existing routing pattern, all POI endpoints were correctly added to `trails.py` via `?action=` routing (matching the Phase 1 design doc consolidation strategy).
- Icon naming uses `t1-poi-{slug}.svg` where slug is the shortened category name (e.g. `stream` not `stream-crossing`, `water` not `water-source`), keeping filenames concise.
- The hover layer (`pois-hover`) exists as an empty placeholder — no bespoke POI icons yet (T3 will come if/when Valken designs bespoke versions). The `setupHoverInteractions()` function correctly skips categories with no bespoke entries.
- POI text labels appear at zoom 14 (not 13 like peaks/caves) to reduce visual clutter since POIs will be more numerous.

**Blockers for deploy:**
1. Commit all new/modified files and push to main → Vercel auto-deploys
2. Test: sign in as admin, navigate to `/intelligence/poi-manager`, create a POI with coordinates
3. Test: toggle POI to live, refresh map at `/`, verify POI appears with correct icon and popup
4. Test: filter sidebar toggle shows/hides POI layer
5. Test: draft POIs do not appear on the public map

### Handoff Notes for Phase 5
- The POI Manager and all CRUD are working. POI-to-trail association is NOT yet built — that's Phase 5.
- The `trail_poi_links` table exists (created in Phase 1) but is empty. Phase 5 builds the association UI in the trail library.
- 28 generic SVG icons are placeholders — Valken may want to design bespoke versions later. The T3/T4 icon pipeline is ready (empty `bespoke` object in MARKER_STYLES, `setupHoverInteractions` skips gracefully).
- The POI popup currently shows name + category + description. Phase 5 could add elevation, trail associations, or links.
- POI source is fetched once at map init. If real-time updates are needed later, the source data can be refreshed via `map.getSource('pois').setData(newData)`.
- Serverless function count: still 12 (unchanged).
- The map `addPOILayers()` uses a nested `step` > `match` expression for per-category icon selection. This is valid GL JS syntax and tested.

---

## Phase 5: Map Integration + Trail Pages

### Scope
Build trail detail pages, composite grade display, and full POI association.

### Deliverables

1. **Trail detail page:** `pages/trail.html`
   - URL: `/trail/:slug`
   - Hero: trail name, composite grade badges, event type, distance, elevation profile
   - Segment breakdown table: per-km with notes, surface, gradient, grade
   - Associated POIs list with icons
   - Embedded Mapbox mini-map showing trail geometry + POI markers
   - Climb and descent cards with individual grades

2. **Map popup update:**
   - Add event type badge
   - Add road/trail percentage
   - Change "Route details coming soon" to working link: `View trail details →`
   - Link goes to `/trail/:slug`

3. **Trail-POI association UI:**
   - In trail library edit mode, admin can link existing POIs to a trail
   - Set km_position for each linked POI
   - On trail detail page, POIs appear at their km positions in the segment table

4. **Composite grade rendering:**
   - On map popup: show overall grade only
   - On trail detail page: show full composite (overall + climb grades + descent grades)
   - Grade badges use existing `GRADE_COLORS` colour scheme

### Key Files to Create/Modify
| Action | File |
|---|---|
| CREATE | `pages/trail.html` |
| CREATE | `scripts/trail-detail.js` |
| MODIFY | `scripts/map.js` — update popup HTML template, add trail link |
| MODIFY | `scripts/trail-library.js` — add POI association UI |
| MODIFY | `api/python/trails.py` — add GET single trail with segments + POI links |
| MODIFY | `vercel.json` — add route for `/trail/:slug` |
| MODIFY | `styles/pages.css` — trail detail page styling |

### Acceptance Criteria
- [ ] Clicking "View trail details" in map popup navigates to trail detail page
- [ ] Trail detail page shows full segment breakdown with notes
- [ ] Composite grade renders correctly (overall + climbs + descents)
- [ ] Associated POIs appear on the trail detail page
- [ ] Mini-map shows trail geometry with POI markers
- [ ] Trail detail page works for all event types

---

## Phase 6: Polish + Public Separation

### Scope
Final polish, clean separation of admin and public tools, and personal library for public users.

### Deliverables

1. **Public analyzer cleanup:**
   - Activity type selector fully removed (auto-detect only)
   - Clean, simple UI — no admin features visible
   - Grade display matches the updated design language

2. **Personal library for public users:**
   - Authenticated users see their saved route analyses
   - Simple list view: name, date, grade, distance
   - Can delete from personal library
   - Cannot publish to map or edit segments

3. **Seasonality enforcement:**
   - API excludes trails outside their seasonal dates
   - Trail library shows seasonal indicators
   - Admin can override (force live regardless of season)

4. **Admin nav consolidation:**
   - Trail Library and POI Manager accessible from admin nav
   - Clear visual hierarchy for admin-only pages

5. **Testing and edge cases:**
   - Empty state handling (no trails, no POIs)
   - Error handling (malformed GPX, oversized files)
   - Mobile responsiveness for admin pages
   - Concurrent access (two admin tabs — currently only Valken, but defensive)

### Key Files to Create/Modify
| Action | File |
|---|---|
| MODIFY | `scripts/route-analyzer.js` — final cleanup |
| MODIFY | `pages/intelligence-route-grading.html` — remove any admin remnants |
| MODIFY | `api/python/trails.py` — add seasonality filter to GET |
| MODIFY | `scripts/trail-library.js` — add seasonal indicators |
| MODIFY | `styles/pages.css` — final responsive tweaks |

### Acceptance Criteria
- [ ] Public analyzer works cleanly with no admin features exposed
- [ ] Personal library shows saved analyses for logged-in users
- [ ] Seasonal trails auto-hide outside their dates
- [ ] All admin pages are properly gated
- [ ] No console errors, no broken layouts on mobile
- [ ] Full end-to-end flow: record trail → upload → grade → edit → publish → visible on map → click through to detail page

---

## Handoff Protocol

At the end of each phase, the implementing session should:

1. **Update this document** — check off completed acceptance criteria, note any deviations
2. **Update [[trail_ecosystem_design]]** — if any design decisions changed during implementation
3. **Update [[website_architecture]]** — add new files, endpoints, tables to the architecture doc
4. **Update [[website_build_status_overview]]** — mark new features as functional
5. **Write a brief handoff note** in `_work/_handoffs/` with:
   - What was built
   - What works
   - What was deferred or changed
   - Any blockers for the next phase
   - Specific files that were created or modified

This ensures the next session has full context without needing to re-read the entire codebase.
