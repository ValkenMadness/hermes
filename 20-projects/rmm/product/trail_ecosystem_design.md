---
title: trail_ecosystem_design
domain: rmm
type: design
status: active
created: 2026-05-18
updated: 2026-05-21
updated_by: claude_cowork
tags: [design, trail-ecosystem, route-analyzer, poi-manager, trail-library, map, admin]
supersedes: ""
related: ["[[map_system_overview]]", "[[map_system_markers_and_interactions]]", "[[formula_lab_build_status_overview]]", "[[website_architecture]]", "[[trail_ecosystem_build_phases]]"]
---

# Trail Ecosystem — Complete Design Document

Master design for the RMM Trail Ecosystem: the admin pipeline through which all curated trail content enters the RMM platform. Designed 2026-05-18. This document is the authoritative reference for all implementation sessions.

---

## 1. Vision Summary

The Route Analyzer evolves from a simple "drop GPX, get a grade" tool into two distinct modes — a **public analyzer** (simple: upload, grade, personal library) and an **admin game-maker tool** that becomes the single pipeline through which all curated trail content enters the RMM ecosystem.

Five interconnected systems:

| # | System | Purpose | Access |
|---|---|---|---|
| 1 | Admin Route Analyzer | GPX intake, grading, event typing, segment editing, snipping | Admin only |
| 2 | Trail Library | Control centre for all trail content — status, seasonality, edits | Admin only |
| 3 | POI Manager | Create and manage map POIs with custom icons | Admin only |
| 4 | Map Integration | Published trails + POIs render on the main map | Public |
| 5 | Public Route Analyzer | Upload GPX, get grade, save to personal library | Authenticated users |

**Core principle:** Valken is the game-maker. All curated trail content enters exclusively through admin tools. Everything has a draft/live toggle. The public never sees unpublished content.

**Key architectural change:** The 8 hardcoded route GeoJSON files in `/public/data/routes/` are removed entirely. All routes on the map come from the database via the admin pipeline.

---

## 2. GPX Data & Accuracy

### Garmin GPX Format

Garmin Connect exports activity GPX files containing `<trk>` elements with `<trkpt>` track points only. Waypoints (`<wpt>` elements) saved on the device are NOT included in activity exports — they live separately on the Garmin device in the `Garmin/GPX/` folder.

**Design decision:** POIs are managed separately from trails. The POI Manager (System 3) handles all point-of-interest data independently. POIs are first-class map entities that exist regardless of which trails pass near them.

### GPS Accuracy: Garmin vs QGIS/Mapbox

| Source | Typical Accuracy | Notes |
|---|---|---|
| Garmin GPS (on-trail recording) | 1–3 metres | Multi-band GPS, actual path walked |
| QGIS / OpenStreetMap traces | 5–20 metres | Derived from satellite imagery or community traces |
| Mapbox trail tilesets | 5–20 metres | Sourced from OSM |

**Rule:** When admin-recorded Garmin GPX data exists for a trail, it becomes the geometry source of truth, replacing any QGIS/Mapbox-derived data.

### Track Point Data Available from Garmin GPX

Each `<trkpt>` provides:
- `lat` / `lon` — GPS coordinates (high precision, ~15 decimal places)
- `<ele>` — elevation in metres
- `<time>` — UTC timestamp
- Extensions: `atemp` (ambient temperature), `hr` (heart rate), `cad` (cadence)

---

## 3. Database Schema

All new tables use Supabase PostgreSQL with PostGIS extension enabled.

### Enable PostGIS (one-time setup)

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

### 3.1 `trails` Table

The primary table for all trail content. Stores geometry, grades, metadata, and publish state.

```sql
CREATE TABLE trails (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name            text NOT NULL,
    slug            text UNIQUE,
    description     text,

    -- Classification
    event_type      text NOT NULL DEFAULT 'trail',
        -- Values: 'trail', 'time_trial', 'hill_climb', 'hill_bomb'
        -- Extensible via event_types table
    status          text NOT NULL DEFAULT 'draft',
        -- Values: 'draft', 'live', 'archived'

    -- Geometry (PostGIS)
    geometry        geometry(LineString, 4326),
    coordinates_json jsonb,
        -- Backup: [[lng, lat, ele], ...] for non-PostGIS access

    -- Grading
    grade                text,        -- A–F
    grade_display        text,        -- e.g. "C3"
    tds                  numeric,     -- Terrain Difficulty Score 1–10
    effort_descriptor    text,        -- Flat/Undulating/Hilly/etc.
    composite_grade      jsonb,
        -- { "overall": "C3", "climbs": [{"grade": "D4", "km_start": 2.0, "km_end": 4.5}],
        --   "descents": [{"grade": "B2", "km_start": 6.0, "km_end": 8.0}] }

    -- Metrics
    total_distance_km       numeric,
    total_elevation_gain    numeric,
    total_elevation_loss    numeric,
    elevation_density       numeric,     -- m/km
    min_elevation           numeric,
    max_elevation           numeric,
    road_percentage         numeric,     -- 0–100
    trail_percentage        numeric,     -- 0–100
    climb_count             integer,
    descent_count           integer,

    -- Data
    elevation_profile    jsonb,        -- [{distance_km, elevation}, ...]
    km_splits            jsonb,        -- per-km split data from GPS processor
    analysis_data        jsonb,        -- full grading result (internal)
    raw_gpx              text,         -- original GPX content

    -- Provenance
    source_activity_id   uuid,         -- FK to activities if uploaded via fitness tracker
    created_by           uuid,         -- FK to users

    -- Seasonality
    seasonal_start       date,         -- null = always available
    seasonal_end         date,

    -- Timestamps
    created_at           timestamptz DEFAULT now(),
    updated_at           timestamptz DEFAULT now()
);

-- Indexes
CREATE INDEX idx_trails_status ON trails(status);
CREATE INDEX idx_trails_event_type ON trails(event_type);
CREATE INDEX idx_trails_geometry ON trails USING GIST(geometry);
```

### 3.2 `trail_segments` Table

Per-km (or per-section) breakdown with admin notes and manual tags.

```sql
CREATE TABLE trail_segments (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    trail_id        uuid NOT NULL REFERENCES trails(id) ON DELETE CASCADE,

    -- Position
    km_start        numeric NOT NULL,
    km_end          numeric NOT NULL,
    sort_order      integer NOT NULL,

    -- Classification
    segment_type    text,
        -- 'climb', 'descent', 'flat', 'rolling'
    terrain_type    text DEFAULT 'trail',
        -- 'trail', 'road' — from manual scrubbing

    -- Manual tags (admin-set after field observation)
    surface_type    text,
        -- 'rock', 'sand', 'gravel', 'dirt', 'paved', null
    track_width     text,
        -- 'single_track', 'jeep_track', 'road', null
    exposure        text,
        -- 'open', 'partial', 'covered', null

    -- Auto-computed metrics
    gradient_avg        numeric,
    gradient_max        numeric,
    gradient_min        numeric,
    elevation_gain      numeric,
    elevation_loss      numeric,
    distance_km         numeric,
    switchback_count    integer,
    gradient_variability numeric,  -- std dev of gradient changes

    -- Grading (for climb/descent segments)
    grade               text,      -- segment-specific A–F
    tds                 numeric,

    -- Admin notes
    notes               text,      -- free-text per-segment notes

    -- Coordinates
    coord_start_idx     integer,   -- index into trail's coordinate array
    coord_end_idx       integer,

    -- Timestamps
    created_at          timestamptz DEFAULT now(),
    updated_at          timestamptz DEFAULT now()
);

CREATE INDEX idx_trail_segments_trail ON trail_segments(trail_id);
```

### 3.3 `trail_pois` Table

Standalone map POIs — independent of trails but associable with them.

```sql
CREATE TABLE trail_pois (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name            text NOT NULL,
    category        text NOT NULL,
        -- 'waterfall', 'stream_crossing', 'info_board', 'viewpoint',
        -- 'parking', 'gate', 'water_source', 'danger', 'rest_area',
        -- 'bridge', 'rock_formation', 'shelter', 'campsite', 'toilets',
        -- 'trailhead', 'summit', 'photo_spot'
    icon_key        text NOT NULL,
        -- Maps to built-in icon library, e.g. 'poi-waterfall'
    custom_icon_url text,
        -- Future: URL to custom uploaded SVG

    description     text,
    latitude        numeric NOT NULL,
    longitude       numeric NOT NULL,
    location        geometry(Point, 4326),
    elevation       numeric,

    status          text NOT NULL DEFAULT 'draft',
        -- 'draft', 'live'

    metadata        jsonb DEFAULT '{}',
        -- Extensible: { "season": "winter", "difficulty": "moderate" }

    created_by      uuid,
    created_at      timestamptz DEFAULT now(),
    updated_at      timestamptz DEFAULT now()
);

CREATE INDEX idx_trail_pois_status ON trail_pois(status);
CREATE INDEX idx_trail_pois_category ON trail_pois(category);
CREATE INDEX idx_trail_pois_location ON trail_pois USING GIST(location);
```

### 3.4 `trail_poi_links` Table

Many-to-many association between trails and POIs.

```sql
CREATE TABLE trail_poi_links (
    trail_id    uuid NOT NULL REFERENCES trails(id) ON DELETE CASCADE,
    poi_id      uuid NOT NULL REFERENCES trail_pois(id) ON DELETE CASCADE,
    km_position numeric,
        -- Approximate km position where the POI is encountered on this trail
    PRIMARY KEY (trail_id, poi_id),
    created_at  timestamptz DEFAULT now()
);
```

### 3.5 `event_types` Table

Extensible event type registry so admin can add new types without code changes.

```sql
CREATE TABLE event_types (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    key             text UNIQUE NOT NULL,
        -- 'trail', 'time_trial', 'hill_climb', 'hill_bomb'
    display_name    text NOT NULL,
    description     text,
    grading_profile text NOT NULL DEFAULT 'standard',
        -- Which grading approach: 'standard', 'climb_focus', 'descent_focus', 'timed'
    is_active       boolean DEFAULT true,
    sort_order      integer DEFAULT 0,
    created_at      timestamptz DEFAULT now()
);

-- Seed default event types
INSERT INTO event_types (key, display_name, description, grading_profile, sort_order) VALUES
    ('trail', 'Trail', 'Standard trail run or hike', 'standard', 1),
    ('time_trial', 'Time Trial', 'Timed segment for competitive tracking', 'timed', 2),
    ('hill_climb', 'Hill Climb', 'Dedicated uphill segment', 'climb_focus', 3),
    ('hill_bomb', 'Hill Bomb', 'Dedicated downhill segment', 'descent_focus', 4);
```

---

## 4. System 1 — Admin Route Analyzer

### 4.1 Workflow

```
1. Drop GPX file
2. Select event type (trail / time trial / hill climb / hill bomb / custom)
3. System auto-processes:
   a. GPS stream processing (existing engine)
   b. Route grading V3 (existing engine)
   c. Trail vs road auto-classification (future: OSM, initial: all trail)
   d. Descent grading (new engine)
   e. Climb/descent segment detection (existing climb detection, extended)
   f. Per-km split generation (existing)
4. Results displayed:
   a. Grade card with composite rating
   b. Elevation profile (interactive)
   c. Trail vs road percentage bar
   d. Per-km segment breakdown table
5. Admin editing mode:
   a. Per-km notes — click any km segment, type notes
   b. Road vs trail scrubbing — select points on profile, paint as road/trail
   c. Segment manual tags — surface type, track width, exposure per segment
   d. Snip segments — select start/end on profile, extract as new standalone trail
6. Save actions:
   a. Save to trail library (always as draft)
   b. Snipped segments save as independent drafts
```

### 4.2 Event Type Grading Profiles

| Event Type | Grading Behaviour |
|---|---|
| `trail` (standard) | Full composite grade: overall + climb grades + descent grades |
| `time_trial` | Grade as standard, but flag as timed segment for leaderboard eligibility |
| `hill_climb` | Climb-focused grading — uses existing climb detection, primary grade reflects climbing difficulty |
| `hill_bomb` | Descent-focused grading — uses new descent grading formula, primary grade reflects descent difficulty |

### 4.3 Road vs Trail Detection

**Phase 1 (initial build):** Manual scrubbing only. The admin sees the full trail on an interactive elevation profile and map. A "terrain type" bar below the elevation profile spans the full distance. The admin can click and drag on this bar to paint sections as "road" or "trail." Default is 100% trail.

**Phase 2 (future enhancement):** Auto-detection by cross-referencing GPS coordinates against OpenStreetMap road network via Overpass API. Pre-paints the terrain bar, admin overrides as needed.

**Classification rules:** Jeep tracks count as trail. Only paved or gravel roads classified as "road."

### 4.4 Segment Snipping

The admin selects a start point and end point on the elevation profile (or map). Clicks "Extract as new trail." The system:

1. Extracts the coordinate subset between start and end
2. Runs the GPS processor on the extracted subset
3. Runs the route grader on the extracted data
4. Creates a new entry in the `trails` table with `status: 'draft'`
5. The snipped trail is fully independent — no parent-child relationship
6. The snipped trail inherits the event type suggested by the admin (e.g. "hill climb" when snipping a climb section)

### 4.5 Activity Type Auto-Detection

**Critical change:** The Route Analyzer should NOT ask the user (or admin) to choose between trail, road, or walk as an activity type. Instead:

- **Trail vs Road** is determined by the processor / manual scrubbing and expressed as a percentage breakdown
- The existing `activity_type` field (`road`, `trail`, `hike`) becomes an internal classification derived from the road/trail percentage and event type:
  - ≥70% road → `road`
  - ≥70% trail → `trail`
  - Mixed → `trail` (default)
  - The admin can override this classification

---

## 5. Descent Grading Formula

### Problem

The current route grader rates downhill-only segments as "easy" because elevation density, TBS, and TDS are all climbing-focused metrics. A gnarly technical descent with switchbacks, loose rock, and steep drops currently gets an A or B grade.

### Solution: Descent Difficulty Score (DDS)

A parallel scoring system for descent segments, using both auto-computed GPS metrics and admin-tagged field observations.

### 5.1 Auto-Computed Metrics (from GPX data)

| Metric | What it measures | How it's computed |
|---|---|---|
| Sustained negative gradient | How steep the descent is | Average gradient across all descent points (more negative = harder) |
| Max negative gradient | Steepest single point | Minimum gradient value in the segment |
| Gradient variability | How choppy/technical the terrain changes are | Standard deviation of gradient values across the descent |
| Switchback density | Number of sharp turns per km | Count of bearing changes >45 degrees within 20m distance between consecutive GPS points |
| Descent rate | How rapidly elevation is lost | Total elevation loss / horizontal distance in km |

### 5.2 Admin-Tagged Attributes

| Attribute | Scale | Values |
|---|---|---|
| Surface difficulty | 1–5 | 1=paved, 2=gravel, 3=packed dirt, 4=loose rock/sand, 5=technical rock |
| Track width | 1–3 | 1=road/jeep track, 2=wide single track, 3=narrow single track |
| Exposure | 1–3 | 1=covered/sheltered, 2=partial cover, 3=fully exposed |

### 5.3 DDS Calculation

```
DDS = (sustained_gradient_score × 0.30)
    + (gradient_variability_score × 0.25)
    + (switchback_density_score × 0.20)
    + (surface_difficulty_score × 0.15)
    + (track_width_score × 0.05)
    + (exposure_score × 0.05)
```

Each component is normalised to 0–10 before weighting. The final DDS (0–10) maps to the same A–F grade system as the existing route grader, using the same BASE_CLASS_MATRIX distance/density bands but with descent-specific thresholds.

**Weights are PROVISIONAL and will need calibration against real trail data.**

### 5.4 Switchback Detection Algorithm

```python
def count_switchbacks(coordinates, min_angle=45, max_distance=20):
    """
    Count significant bearing changes in a GPS track.
    A switchback = bearing change > min_angle degrees within max_distance metres.
    """
    count = 0
    for i in range(1, len(coordinates) - 1):
        bearing_in = bearing(coordinates[i-1], coordinates[i])
        bearing_out = bearing(coordinates[i], coordinates[i+1])
        angle_change = abs(bearing_out - bearing_in) % 360
        if angle_change > 180:
            angle_change = 360 - angle_change
        dist = haversine(coordinates[i-1], coordinates[i+1])
        if angle_change >= min_angle and dist <= max_distance:
            count += 1
    return count
```

### 5.5 Composite Grade Display

With descent grading, a full trail report produces a composite grade:

```
"This trail is C3 overall, with 2 climbing sections rated D4 and 1 downhill section rated B2"
```

Stored in `trails.composite_grade` as:
```json
{
    "overall": "C3",
    "overall_tds": 4.2,
    "climbs": [
        {"grade": "D4", "tds": 5.8, "km_start": 2.0, "km_end": 4.5, "elevation_gain": 380},
        {"grade": "D4", "tds": 6.1, "km_start": 7.0, "km_end": 9.2, "elevation_gain": 420}
    ],
    "descents": [
        {"grade": "B2", "dds": 3.5, "km_start": 4.5, "km_end": 7.0, "elevation_loss": 350}
    ],
    "road_percentage": 32,
    "trail_percentage": 68
}
```

---

## 6. System 2 — Trail Library

### 6.1 Purpose

The admin control centre for all trail content. Every trail that enters the system (via admin Route Analyzer or segment snipping) lands here.

### 6.2 Features

| Feature | Description |
|---|---|
| List all trails | Table view with name, event type, grade, status, distance, last updated |
| Filter/sort | By status (draft/live/archived), event type, grade |
| Toggle live/draft | One-click toggle per trail — immediately affects map visibility |
| Seasonal toggle | Set start/end dates; trail auto-hides outside season |
| Edit trail info | Name, description, event type |
| Manage segments | View/edit per-km notes, surface tags, terrain type |
| Manage POI links | Associate existing POIs with the trail, set km positions |
| Refine geometry | Upload additional GPX files to improve accuracy — merge/average coordinates |
| View on map | Preview the trail on a mini-map within the library |
| Archive | Soft-delete — trail is hidden but not destroyed |

### 6.3 Geometry Refinement (Multi-GPX Merge)

When the admin has recorded the same trail multiple times, they can upload additional GPX files to refine accuracy. The merge algorithm:

1. Align tracks by matching start/end coordinates (within 50m tolerance)
2. Resample all tracks to uniform point spacing (e.g. every 5m)
3. Average lat/lon at each sample point across all tracks
4. Smooth the result with a rolling window
5. Replace the trail's geometry with the averaged result
6. Keep all original GPX files as `raw_gpx` for provenance

This is a Phase 3+ feature — not needed for initial launch.

### 6.4 UI Location

Admin-only page at `/intelligence/trail-library` (or `/admin/trails`). Gated behind `RMMAuth.isAdmin()` check.

---

## 7. System 3 — POI Manager

### 7.1 Purpose

Create and manage standalone map POIs. POIs are first-class map entities — they exist on the map independently of any trail. A waterfall exists at its coordinates regardless of which trails pass by it.

### 7.2 Workflow

```
1. Click "Add POI" on the POI Manager page
2. Enter coordinates:
   a. Type lat/lon manually, OR
   b. Click on an embedded Mapbox map to pick a location (future)
3. Select category from dropdown (waterfall, stream crossing, etc.)
4. Select icon from built-in library (auto-matched to category)
5. Enter name (required)
6. Enter description (optional)
7. Set status: draft or live
8. Save → POI appears on map if status is live
```

### 7.3 Built-In Icon Library (Phase 1)

Generic icons that serve as placeholders until Valken designs bespoke versions. Following the existing t0–t4 naming convention:

| Category | Icon Key | Filename |
|---|---|---|
| Waterfall | `poi-waterfall` | `t1-poi-waterfall.svg`, `t2-poi-waterfall.svg` |
| Stream Crossing | `poi-stream` | `t1-poi-stream.svg`, `t2-poi-stream.svg` |
| Info Board | `poi-info` | `t1-poi-info.svg`, `t2-poi-info.svg` |
| Viewpoint | `poi-viewpoint` | `t1-poi-viewpoint.svg`, `t2-poi-viewpoint.svg` |
| Parking | `poi-parking` | `t1-poi-parking.svg`, `t2-poi-parking.svg` |
| Gate / Entrance | `poi-gate` | `t1-poi-gate.svg`, `t2-poi-gate.svg` |
| Water Source | `poi-water` | `t1-poi-water.svg`, `t2-poi-water.svg` |
| Danger / Warning | `poi-danger` | `t1-poi-danger.svg`, `t2-poi-danger.svg` |
| Rest Area | `poi-rest` | `t1-poi-rest.svg`, `t2-poi-rest.svg` |
| Bridge | `poi-bridge` | `t1-poi-bridge.svg`, `t2-poi-bridge.svg` |
| Rock Formation | `poi-rock` | `t1-poi-rock.svg`, `t2-poi-rock.svg` |
| Shelter / Hut | `poi-shelter` | `t1-poi-shelter.svg`, `t2-poi-shelter.svg` |
| Trailhead | `poi-trailhead` | `t1-poi-trailhead.svg`, `t2-poi-trailhead.svg` |
| Photo Spot | `poi-photo` | `t1-poi-photo.svg`, `t2-poi-photo.svg` |

Icons stored in `/public/icons/pois/`. Follow the same SVG-to-canvas rasterisation pipeline as peaks and caves. Added to `MARKER_STYLES` config in `map.js`.

### 7.4 UI Location

Admin-only page at `/intelligence/poi-manager` (or `/admin/pois`). Gated behind `RMMAuth.isAdmin()`.

---

## 8. System 4 — Map Integration

### 8.1 Changes to Map System

**Remove:**
- All 8 GeoJSON files in `/public/data/routes/`
- The `loadRMMRoutes()` function's file-fetching logic (8 sequential fetches)
- The hardcoded route names and properties

**Replace with:**
- A single API endpoint (`/api/python/trails` or `/api/trails`) that returns all published trails as GeoJSON FeatureCollection
- The map fetches this endpoint at init and renders the results using the existing `rmm-routes`, `rmm-routes-highlight`, `rmm-route-labels`, and `rmm-route-starts` layers
- POIs load from a separate endpoint (`/api/python/pois` or `/api/pois`) and render as a new layer group

### 8.2 Trail Rendering

Published trails render exactly as the current routes do — same line styling, same hover-to-reveal pattern, same popup format, same pulse animation. The only change is the data source (API instead of static files).

The popup content expands to show:
- Grade display (existing)
- Distance + elevation gain + elevation density (existing)
- Event type badge (new)
- Road/trail percentage (new)
- "View trail details →" link to trail detail page (new, replaces "Route details coming soon")

### 8.3 POI Rendering

POIs render as a new marker layer group, following the existing two-layer pattern:
- Base layer (`pois`): T1 icons at zoom < 13, T2 at zoom ≥ 13
- Future: T3 hover layer for bespoke icons

POIs are added to `MARKER_STYLES` config:
```javascript
pois: {
    source: 'pois',
    icons: {
        t1: { /* per-category t1 icons */ },
        t2: { /* per-category t2 icons */ }
    },
    iconSwitch: 13,
    filter: null,
    layerId: 'pois',
    hoverLayerId: 'pois-t3-hover'
}
```

POI icon selection uses a GL `match` expression on the `category` property to pick the correct icon per feature.

### 8.4 Trail Detail Pages

New page at `/trail/:slug` showing the full trail breakdown:
- Hero: trail name, composite grade, event type, distance, elevation profile
- Segment breakdown: per-km table with notes, surface tags, terrain type
- POIs: list of associated POIs with icons
- Map: embedded mini-map showing the trail geometry with POI markers
- Climb and descent cards: individual grade cards for each climb/descent segment

This is the "click-through" from the main map popup.

### 8.5 Filter Sidebar Update

Add POIs to `FILTER_GROUPS`:
```javascript
FILTER_GROUPS.markers.items.push('pois');
```

Remove the `future` placeholder for POIs since they are now implemented.

### 8.6 Seasonality

Trails with `seasonal_start` and `seasonal_end` dates are automatically excluded from the API response when the current date falls outside their season. The admin can manually override by toggling the trail to `live` regardless of season.

---

## 9. System 5 — Public Route Analyzer

### 9.1 Scope (Unchanged)

The public Route Analyzer remains simple:
- Drop GPX file
- Get grade (A–F, TDS, effort descriptor)
- View elevation profile
- Save to personal library (linked to user account)

### 9.2 What Public Users Do NOT Get

- No event type selection
- No segment editing
- No per-km notes
- No road/trail scrubbing
- No snipping
- No map publishing
- No POI management
- No trail library management

### 9.3 Personal Library

Authenticated users can save analyzed routes to their own library (stored in `route_analyses` table, linked to their user ID). They can view past analyses but cannot publish them to the map. This is the existing behaviour, unchanged.

### 9.4 Activity Type Removal

The public analyzer currently shows radio buttons for "Trail / Road / Walk." Per the design decision in Section 4.5, this selector is removed. The analyzer auto-classifies based on the GPS data. The activity type field is set internally and not exposed to the user.

---

## 10. API Endpoints

### Vercel Function Count — CRITICAL CONSTRAINT

The Vercel Hobby plan allows a maximum of 12 serverless functions. The current count is **exactly 12**:

**JS (7):** `subscribe.js`, `auth/account.js`, `auth/logout.js`, `auth/session.js`, `auth/strava-activities.js`, `auth/strava-callback.js`, `auth/strava-login.js`

**Python (5):** `analyze.py`, `calculate_rps.py`, `race_readiness_check.py`, `recalculate_decay.py`, `upload.py`

**Helper modules (don't count):** `_config.py`, `_supabase.py`, `_gps_processor.py`, `_route_grader.py`, `_rps_engine.py`, `_race_readiness.py`, `_anti_gaming.py`, `_dem_lookup.py`

Adding `trails.py` and `pois.py` would make 14 — **over the limit by 2**.

### Consolidation Strategy

**Merge `analyze.py` into `upload.py`** as an unauthenticated action. Both files handle GPX processing; `analyze.py` is just a simpler version without database writes. The `upload.py` action routing becomes:
- `POST` multipart + no auth cookie → public analyze (grade only, no DB write) — replaces `analyze.py`
- `POST` multipart + auth cookie → authed upload + grade + store (existing)
- `POST` JSON body → action routing: toggle, merge, etc. (existing)
- `GET` → history (existing)

This frees one slot. Then:
- **CREATE `trails.py`** — all trail CRUD + snipping + event types + all POI CRUD, using `?action=` routing

Final function count: **12** (same as before — `analyze.py` removed, `trails.py` added).

### Endpoint Routing in `trails.py`

| Action | Method | Auth | Query Params | Purpose |
|---|---|---|---|---|
| List published trails | GET | None | `?action=list` (default) | Returns GeoJSON for map |
| Get single trail | GET | Admin | `?action=detail&id=<uuid>` | Full trail with segments + POI links |
| Create trail from GPX | POST | Admin | `?action=create` (multipart) | Upload GPX, process, grade, save as draft |
| Update trail | POST | Admin | `?action=update` (JSON body) | Status, name, segments, tags |
| Snip segment | POST | Admin | `?action=snip` (JSON body) | Extract coord subset as new draft |
| List event types | GET | Admin | `?action=event-types` | Returns event_types table rows |
| List POIs | GET | None | `?action=pois` | Returns published POIs as GeoJSON for map |
| Create POI | POST | Admin | `?action=create-poi` (JSON) | Insert new POI |
| Update POI | POST | Admin | `?action=update-poi` (JSON) | Update POI status, details |
| Delete POI | POST | Admin | `?action=delete-poi` (JSON) | Soft-delete (status → archived) |

### Changes to `upload.py`

Absorbs `analyze.py` functionality. Public GPX analysis (no auth) detected by absence of session cookie:
- No auth cookie + multipart POST → run GPS processor + route grader → return grade JSON (no DB write)
- Auth cookie + multipart POST → existing upload flow (process + grade + store)
- Remove `activity_type` from required form fields in both paths. Auto-detect internally.

### Vercel Routing (`vercel.json` additions)

```json
{ "source": "/api/python/trails", "destination": "/api/python/trails.py" },
{ "source": "/api/python/pois", "destination": "/api/python/trails.py" }
```

The `/api/python/pois` rewrite routes to `trails.py` which detects the POI resource from the URL path.

### Files Changed

| Action | File |
|---|---|
| CREATE | `api/python/trails.py` (new serverless function) |
| CREATE | `api/python/_descent_grader.py` (helper module, underscore-prefixed) |
| DELETE | `api/python/analyze.py` (absorbed into upload.py) |
| MODIFY | `api/python/upload.py` (absorbs public analyze) |
| MODIFY | `vercel.json` (new rewrites) |

### Existing Endpoint Changes

| Endpoint | Change |
|---|---|
| `/api/python/analyze` | **REMOVED** — rewrite in `vercel.json` points `/api/python/analyze` to `upload.py` for backward compat |
| `/api/python/upload` | Absorbs public analyze. Detects auth vs no-auth to choose flow. |
| `/api/auth/session.js` (mapconfig) | No changes needed |

---

## 11. New Pages

| URL | File | Purpose | Access | Status |
|---|---|---|---|---|
| `/intelligence/trail-library` | `pages/intelligence-trail-library.html` | Trail Library admin interface | Admin | LIVE |
| `/intelligence/poi-manager` | `pages/intelligence-poi-manager.html` | POI Manager admin interface | Admin | LIVE |
| `/trail/:slug` | `pages/trail.html` | Public trail detail page | Public | LIVE |
| `/trails` | `pages/trails.html` | Public trail browse/discovery page | Public | LIVE |

### New Scripts

| File | Purpose | Status |
|---|---|---|
| `scripts/trail-library.js` | Trail Library UI — table, filters, status toggles, segment editor, snip tool, POI linking | LIVE |
| `scripts/poi-manager.js` | POI Manager UI — CRUD form, library table, DDM coordinate converter, map preview, icon preview | LIVE |
| `scripts/trail-detail.js` | Trail detail page — composite grades, segments, linked POIs, elevation profile SVG, mini-map | LIVE |
| `scripts/trail-browse.js` | Trail browse page — filterable/sortable trail cards with grade badges, stats, and detail links | LIVE |

**Note:** `admin-route-analyzer.js` was merged into `trail-library.js` — all admin route analyzer and trail library UI lives in one file.

---

## 12. Descent Grading — Implementation Notes

### Where It Fits in the Processing Pipeline

The descent grading runs as a post-processing step after the existing GPS processor and route grader:

```
GPX → GPS Stream Processor → Route Grader V3 → Descent Grader (new)
                                                      ↓
                                              Composite Grade Builder
```

### New File

`api/python/_descent_grader.py` — pure Python, no dependencies. Consumes the output of `_gps_processor.py` (coordinates, elevation profile, km splits) and produces descent difficulty scores per descent segment.

### Integration with Existing Climb Detection

The existing `_gps_processor.py` has a climb detection state machine. This needs to be extended to also detect descent segments using the same state machine approach but tracking sustained negative gradients. Each detected descent segment gets:
- Start/end km positions
- Elevation loss
- Auto-computed DDS metrics
- A descent grade (A–F)

---

## 13. POI Icon Design Specification

### Style Requirements

All POI icons must match the existing RMM visual language:
- Dark olive primary (`#171A14`)
- Warm white fill/highlight (`#F5ECD7`)
- Coral red accent (`#FF4E50`) for emphasis elements
- Clean, minimal line art — no gradients, no 3D effects
- Square canvas: T1=24px, T2=32px (matching peaks/caves)
- SVG format only

### Initial Generic Set

The Phase 1 icon set should be simple, recognizable symbols. These are placeholders — Valken will design bespoke versions later. The generic set should be functional and clean enough to ship.

---

## 14. Architecture Rules Compliance

| Rule | Compliance |
|---|---|
| No React | All new pages use vanilla JS. Admin tools are HTML + vanilla JS. |
| No npm dependencies | All new code is pure browser JS (frontend) and pure Python stdlib (backend). |
| GeoJSON = geographic truth | Shifted: database (PostGIS) becomes geographic truth for trails/POIs. Static GeoJSON files (peaks, caves) remain unchanged. |
| Supabase = operational truth | Trail status, seasonality, POI metadata — all in Supabase. |
| Map never imports code | Map reads trail/POI data via API fetch, no module imports. |
| Vercel 12-function limit | Merge `analyze.py` into `upload.py`, add 1 new function (`trails.py`). Net change: 0. Total stays at 12. |
| All formula values external | Descent grading weights will be env vars, following existing pattern. |
| Secrecy Rule | Descent grading formula values not exposed in public API responses. |

---

## 15. Data Migration Plan

### Removing Hardcoded Routes

1. Delete all 8 files in `/public/data/routes/`
2. Remove the file-fetching loop in `loadRMMRoutes()` inside `map.js`
3. Replace with a single `fetch('/api/python/trails')` call
4. The response format should match the existing GeoJSON FeatureCollection structure so the downstream layer code (highlight, labels, starts, pulse, clusters) requires minimal changes
5. `window._rmmRouteCoords` population logic stays the same — just fed from the API response instead of file fetches

### Preserving Existing Route Data (Optional)

The 8 existing route GeoJSON files could be imported into the new `trails` table as seed data if desired. However, per the design intent, these should be re-recorded with Garmin GPS for better accuracy. Recommendation: delete them cleanly and start fresh through the admin pipeline.

---

## 16. Implementation Status & Deviations (2026-05-19)

This section documents what was actually built vs. what was specified, across Phases 1–3.

### 16.1 What Was Built As Specified
- Database schema (Section 3): All 5 tables created exactly as designed, with PostGIS enabled.
- GPX processing pipeline (Section 4.1 steps 1–4): Works end-to-end. GPX → GPS Stream Processor → Route Grader V3 → Descent Grader → Composite Grade.
- DDS formula (Section 5.3): Implemented exactly as specified with all 6 weighted components. Switchback detection algorithm matches the pseudocode.
- Trail Library features (Section 6.2): List, filter/sort, toggle live/draft, edit trail name, manage segments (notes + tags), view on map preview, archive. All working.
- Segment snipping (Section 4.4): Works as specified — extracts coordinate subset, runs full grading pipeline, creates independent draft.
- Composite grade display (Section 5.5): Stored in `composite_grade` JSONB exactly as shown.
- `analyze.py` consolidation into `upload.py` (Section 10): Done. Function count stays at 12.
- All trail CRUD consolidated in `trails.py` via `?action=` routing (Section 10).
- Activity type removal from public analyzer (Section 9.4): Done. Hardcoded to 'trail'.

### 16.2 Design Deviations

| Spec | Implementation | Reason |
|---|---|---|
| **Interactive elevation profile** with clickable km markers for segment editing (Section 4.1 step 5a) | Separate **segment editor modal** opened via "Segments" button in library table. Each km shown as a card with editable fields. | Simpler, more practical. Avoids complex SVG click interaction code. The modal approach gives more room for the editing UI. |
| **Click-drag road/trail painting** on terrain bar (Section 4.3) | Per-segment **trail/road toggle** switch on each segment card. Scrub bar shows aggregate distribution (read-only visual). | Click-drag painting across an SVG bar is fragile and hard to make precise. Per-segment toggles are clearer and less error-prone. |
| **Select start/end on elevation profile** for snipping (Section 4.4) | Numeric **start km / end km inputs** in the snip tool section of the segment modal. | More precise. Avoids needing SVG coordinate-to-km translation. |
| **Admin tags per descent segment** editable inline (Section 5.2) | Admin tags (surface, width, exposure) default to mid-values (3, 2, 2) on creation. Editable via the segment editor modal after creation. | Defaults ensure DDS produces a meaningful grade immediately. Admin can refine later after field observation. |
| **`sessions` table for auth** (implied by Phase 2 spec) | Auth uses `users.session_token` column directly — no separate sessions table. | Matches the existing auth pattern established in the email/password auth system. The sessions table was never created. |
| **Map preview in elevation profile** | Map preview in a **separate modal** opened from library table "View on Map" button. Uses Mapbox GL JS with trail line overlay. | Cleaner separation of concerns. Admin can preview any trail from the library, not just the one being uploaded. |
| **`coordinates_json` vs PostGIS for API responses** (Section 3.1) | `coordinates_json` JSONB is the primary source for all GeoJSON API responses. PostGIS `geometry` column is populated but not yet queried. | Avoids needing PostGIS functions in the Supabase REST API layer. PostGIS will be used for spatial queries in Phase 5. |
| **Separate `admin-route-analyzer.js`** (Section 11) | All admin route analyzer + trail library UI in a single `trail-library.js` file. | The analyzer and library are on the same page, so a single JS file is simpler. |

### 16.3 Implementation Status — Phases 4–6 (Updated 2026-05-21)

**Phase 4 — POI System: COMPLETE (2026-05-20)**
- ~~POI Manager (System 3 — Section 7):~~ **COMPLETE.** Admin UI at `/intelligence/poi-manager`, CRUD endpoints in `trails.py`, 28 SVG icons, map POI layer with per-category icons and popup.
- ~~POI icon library (Section 7.3 / 13):~~ **COMPLETE.** 14 categories × T1 (24px) + T2 (32px) in `/public/icons/pois/`.
- ~~Map POI layer integration (Section 8.3):~~ **COMPLETE.** POI source from API, `addPOILayers()` with match expressions, popup on hover, filter sidebar toggle.
- ~~POI map preview in admin:~~ **COMPLETE.** "View on Map" button opens Mapbox modal showing POI location with T2 icon.
- ~~POI hover popup simplification:~~ **COMPLETE.** Map shows name-only on hover, click opens detail popup with category and description.

**Phase 5 — Trail Detail Pages + Trail-POI Linking: COMPLETE (2026-05-21)**
- ~~Trail detail pages at `/trail/:slug` (Section 8.4):~~ **COMPLETE.** Public page showing grade card, composite grades (climb + descent cards), stats, elevation profile (SVG), mini-map (Mapbox with trail line + start/end markers), segments, and linked POIs. Only returns `status=live` trails.
- ~~Map popup "View trail details" link (Section 8.2):~~ **COMPLETE.** Both popup locations (cluster click + single-trail hover) now show event type badge, road percentage, and "View trail details →" link. Popup has 350ms linger delay so users can click the link.
- ~~Trail-POI association UI (Section 8.4):~~ **COMPLETE.** POI linking section added to segment editor modal in Trail Library. Select POI from dropdown, set km position, link/unlink. Linked POIs display on public trail detail page.
- ~~Event type labels in popups:~~ **COMPLETE.** `_eventLabel()` helper maps raw values (time_trial, hill_climb, hill_bomb) to display labels (Time Trial, Hill Climb, Hill Bomb) in map popups.
- ~~Seasonality enforcement (Section 8.6):~~ **COMPLETE.** `_get_trails()`, `_browse_trails()`, and `_get_trail_detail()` all filter by `seasonal_start`/`seasonal_end` against current date.

**Phase 6 — Polish + Public Separation: COMPLETE (2026-05-21)**
- ~~Public trail browse page:~~ **COMPLETE.** New `/trails` page with filterable/sortable cards showing all live trails. Filters: grade (A–F), event type. Sort: name, hardest first, longest, most climb. Public — no auth required.
- ~~404 page:~~ **COMPLETE.** On-brand "Trail not found" page at `/404.html` (project root for Vercel auto-serving). Nav + footer, link back to map.
- ~~Nav update for public users:~~ **COMPLETE.** Public nav now shows: Map | Trails | About | Sign In. "Trails" link added to both nav and footer for all users.
- ~~Event type mismatch fix:~~ **COMPLETE.** `trail-detail.js` EVENT_LABELS aligned with actual event types used in trail library (trail, time_trial, hill_climb, hill_bomb).

**Still Deferred (Future Phases)**
- Public personal library (Section 9.3): Existing `route_analyses` table, no dedicated UI.
- Road/trail auto-detection via OSM (Section 4.3 Phase 2): Not started.
- Multi-GPX merge for geometry refinement (Section 6.3): Deferred.
- Dynamic category management for POIs: Planned — admin UI to add/edit/remove POI categories without code changes.
- Icon redesign: Valken will design bespoke POI icons before introducing POIs to the public ecosystem. Current icons are functional placeholders.

---

## 17. Open Questions for Calibration

These items need real-world testing and calibration:

1. **DDS weights** — The 0.30/0.25/0.20/0.15/0.05/0.05 split is provisional. Needs testing against known trails with varying descent difficulty.
2. **Switchback detection thresholds** — 45 degree minimum angle and 20m maximum distance are starting points. May need tuning for different GPS sampling rates.
3. **Road/trail auto-detection accuracy** — When OSM integration is added, the matching radius (15m default) may need adjustment for different terrain types.
4. **Descent-specific grade boundaries** — The DDS-to-grade mapping may need its own matrix rather than sharing the climbing-focused BASE_CLASS_MATRIX.
5. **Multi-GPX merge algorithm** — The averaging approach may need weighting (newer recordings weighted higher, or recordings with better GPS signal quality weighted higher).
