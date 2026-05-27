---
title: map_system_terrain_layers
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-01
updated_by: claude_opus_cowork
tags: [codebase, map, geojson, trails]
supersedes: ""
related: ["[[map_system_overview]]", "[[map_system_markers_and_interactions]]", "[[base_map_visual_design]]"]
---

# Map System — Contours, Trails, Routes

The map is the primary product of the RMM platform. This document covers every layer, system, and behaviour in [scripts/map.js](scripts/map.js) at implementation level. Read this before touching any map code.

---

## 4. Contour Lines

**Source:** Vector tileset, loaded only when `config.contoursTilesetId` is a non-empty string (set via `CONTOURS_TILESET_ID` env var and delivered by `/api/config`). Currently this env var is empty — the contour layer does not render in the current deployment.

```javascript
map.addSource('rmm-contours', {
    type: 'vector',
    url: 'mapbox://' + config.contoursTilesetId
});
```

**Source layer name:** `'10m_Contours-57qbiw'` — hardcoded in the `addLayer` call; must match the actual tileset's source layer ID.

**Layer:** `rmm-contours` — a single `line` layer using data-driven expressions to style 100m intervals (major) differently from 20m intervals (minor).

**Styling (all values in `CONTOUR_STYLES`):**

| Property | Major (100m) | Minor (20m) |
|---|---|---|
| Color | `#a89b70` (warm gold) | `#c4b990` (lighter gold) |
| Width at zoom 12 | 0.3px | 0px (invisible) |
| Width at zoom 13 | 0.4px | 0.3px |
| Width at zoom 16 | 0.6px | 0.5px |
| Opacity at zoom 12 | 0.20 | 0 |
| Opacity at zoom 13 | 0.25 | 0.25 |
| Opacity at zoom 16 | 0.30 | 0.40 |
| Minimum zoom | 12 | 12 (same layer) |

The filter `['==', ['%', ['get', 'ELEV'], 20], 0]` ensures only 20m-interval contours are drawn (filters out 10m intermediate lines). Within the layer, `['==', ['%', ['get', 'ELEV'], 100], 0]` distinguishes major from minor.

---


## 5. Trail Lines

**Source:** Vector tileset, loaded only when `config.trailsTilesetId` is set. Source layer name: `'trails-4ee5we'` — hardcoded in all four layer definitions.

**Four layers**, each filtered by the `trail_type` feature property:

| Layer ID | Filter | Style |
|---|---|---|
| `rmm-trails-footway` | `trail_type == 'footway'` | Solid, `#8a7e60`, 0.5 opacity, appears at zoom 13 |
| `rmm-trails-steps` | `trail_type == 'steps'` | Dashed `[1, 2]`, `#8a7e60`, 0.4 opacity, appears at zoom 14 |
| `rmm-trails-track` | `trail_type == 'track'` | Solid, `#5a5240` (darker), 0.3–0.7 opacity by zoom |
| `rmm-trails-path` | `trail_type == 'path'` | Dashed `[4, 3]`, `#3a3428` (darkest), 0.5–0.9 opacity by zoom |

All trail colour, width, opacity, and dash values live in the `TRAIL_STYLES` config object at the top of [scripts/map.js](scripts/map.js). The layer code reads from this object; **never edit the `addLayer` calls directly for styling**.

Width interpolation uses the same zoom stops across all types (z10 → z13 → z16), with `line-join: round` and `line-cap: round` (steps use `line-cap: butt`).

---


## 6. GeoJSON Routes

### File Structure

Eight GeoJSON files in [public/data/routes/](public/data/routes/), listed in `RMM_ROUTES` array:

```javascript
var RMM_ROUTES = [
    '/public/data/routes/Elsies-Peak-Route-1.geojson',
    '/public/data/routes/Elsies-Peak-Route-2.geojson',
    '/public/data/routes/Elsies-Peak-Route-3.geojson',
    '/public/data/routes/Silvermine-Lower-Route-1.geojson',  // placeholder (385B)
    '/public/data/routes/Silvermine-Lower-Route-2.geojson',
    '/public/data/routes/Silvermine-Lower-Route-3.geojson',
    '/public/data/routes/Silvermine-Lower-Route-4.geojson',
    '/public/data/routes/Silvermine-Lower-Route-5.geojson',
];
```

Each file is a GeoJSON `FeatureCollection` with a non-standard `crs.properties` block used to store route-level metadata, and one `Feature` with `MultiLineString` geometry (3D coordinates: `[lng, lat, elevation_m]`).

**CRS block (route metadata — non-standard use):**
```json
"crs": { "type": "name", "properties": {
    "name": "Elsies Peak - Route 1",
    "grade": "A",
    "tds": 9,
    "distance_km": 3.5,
    "elevation_gain_m": 226,
    "elevation_density": 64.0,
    "effort_descriptor": "Sustained Ascent",
    "grade_display": "Class A · 9/10 — Sustained Ascent"
}}
```

**Feature properties (what Mapbox GL actually reads):**
```json
"properties": {
    "name": "RMM - Trail - Elsies Peak - Route 1",
    "cmt": null, "desc": null, "src": null, ...
}
```

**Important (resolved 2026-04-27):** The grade, TDS, distance, and elevation metadata live in `crs.properties`. `loadRMMRoutes()` now performs a JS-side merge step that copies `crs.properties` fields into each Feature's `properties` object at load time (no GeoJSON files are edited). Fields merged: `name` (as `display_name`), `grade`, `tds`, `distance_km`, `elevation_gain_m`, `elevation_density`, `grade_display`, `effort_descriptor`. The popup now renders `props.grade_display`, `props.distance_km`, `props.elevation_gain_m`, and `props.elevation_density` correctly. Tracked in [[website_build_status_issues]] as Bug 1 (closed).

### Loading Process (`loadRMMRoutes()`)

1. Fetches all 8 files sequentially (not parallel — uses `for` loop with `await`)
2. Concatenates all features into a single array
3. Builds `window._rmmRouteCoords` — a `{ routeName: coordinates[] }` lookup used by the pulse animation. Keyed by `feature.properties.name`. Complete coordinates stored here because `querySourceFeatures()` returns tile-clipped (incomplete) coordinates.
4. Builds a `startFeatures` array — one `Point` feature per route, at `coordinates[0]` of each LineString, copying all Feature properties
5. Adds two GeoJSON sources: `rmm-routes` (the lines) and `rmm-route-starts` (the start points)
6. Adds four layers on top of the sources
7. Wires hover and click interactions

### Route Layers

**`rmm-routes`** — base line layer:
- Color: **grade-driven `match` expression** on `properties.grade` — A → red (hardest), B → orange, C → amber, D → mid, E → muted, F → muted (easiest), with a fallback colour for missing grades. The hardcoded `#FF4E50` was replaced 2026-04-30 (Stage 3 grade-colour milestone). Edit the colour values inside the match arms in `loadRMMRoutes()` to retune the palette.
- Width: interpolated 1.5px (zoom 8) → 5px (zoom 16)
- Opacity: `0` by default; raised to `1.0` on the hovered route via filter on `rmm-routes-highlight` (the base layer stays hidden until the route is hovered — see `website_build_status_overview` for the 2026-04 hover-reveal change)
- `line-emissive-strength: 0.5` — slight glow for the GL3 renderer

**`rmm-routes-highlight`** — hover state line layer:
- Same source, same grade-driven colour expression as `rmm-routes`
- Width: slightly wider — 2px (zoom 8) → 6px (zoom 16)
- Opacity: `1.0` (full)
- Default filter: `['==', ['get', 'name'], '']` — matches nothing; shown by setting filter to specific route name on hover

**`rmm-route-labels`** — text label along route lines:
- `symbol-placement: 'line-center'` — label sits at midpoint of each line
- Text from `['get', 'name']` feature property
- Font: Space Mono Regular, DIN Pro Regular, Arial Unicode MS Regular (fallback chain)
- Text size: interpolated 10px (zoom 12) → 14px (zoom 16)
- Color: `#FF4E50`; halo: `#171A14` (dark olive), width 2
- Opacity: `0.5` default, bumped to `1.0` for hovered route via `setPaintProperty`
- `minzoom: 12` — labels invisible before zoom 12

**`rmm-route-starts`** — circle markers at route start points:
- Circle radius: interpolated 3px (zoom 8) → 7px (zoom 15)
- Color: `#FF4E50`, opacity `0.7`
- White stroke, width 2, opacity 0.9
- Hover on this layer triggers the popup

---


## 11. GeoJSON Data

### Peaks (`public/data/peaks.geojson`, 22KB)

FeatureCollection of 65 named peaks. Point geometry.

**Feature properties:**

| Property | Type | Example |
|---|---|---|
| `name` | string | `"Lion's Head"` |
| `ele` | number | `669.0` (metres) |
| `name_en` | string | `"Lion's Head"` |
| `name_af` | string | `"Leeukop"` |
| `osm_id` | string | `"48944401"` |

The map currently reads only `name` (for labels, bespoke icon matching, hover filter). `ele`, `name_af`, `osm_id` are available for future use (popups, tooltips, filtering by elevation range).

### Caves (`public/data/caves.geojson`, 14KB)

FeatureCollection sourced from OpenStreetMap (CRS84). Point geometry.

**Feature properties (full schema):**

| Property | Type | Notes |
|---|---|---|
| `fid` | integer | Internal sequence ID |
| `full_id` | string | OSM node full ID (e.g. `n473139542`) |
| `osm_id` | string | OSM numeric ID |
| `osm_type` | string | Always `"node"` |
| `natural` | string | Always `"cave_entrance"` |
| `ele` | string / null | Elevation in metres (inconsistent: some numeric, some null) |
| `name` | string / null | Cave name; **null for unnamed entrances** — filtered out by `['has', 'name']` |
| `description` | string / null | Informal description |
| `access` | string / null | `"yes"`, `"no"`, or null |
| `fee` | string / null | `"yes"`, `"no"`, or null |
| `wikidata` | string / null | Wikidata QID |
| `direction` | string / null | Compass bearing (rare) |

The map reads only `name`. All other properties are available for future popup content.

### Routes (`public/data/routes/*.geojson`, 11–30KB each)

**Geometry:** `MultiLineString` with 3D coordinates `[longitude, latitude, elevation_m]`. The elevation (Z) coordinate is present on all points and represents GPS altitude in metres above sea level.

**Feature properties (in GeoJSON file — what Mapbox GL reads):**

| Property | Value (current) |
|---|---|
| `name` | Long-form name e.g. `"RMM - Trail - Elsies Peak - Route 1"` |
| `cmt`, `desc`, `src`, `link*`, `number`, `type` | All `null` (GPX export artefacts) |

After the 2026-04-27 fix, `loadRMMRoutes()` merges `crs.properties` into each Feature's `properties` at load time, so all of the metadata fields below are also available to Mapbox GL expressions and popups at runtime.

**Route metadata (in `crs.properties` on disk — merged into Feature `properties` at load time):**

| Property | Example |
|---|---|
| `name` | `"Elsies Peak - Route 1"` (short name) |
| `grade` | `"A"` |
| `tds` | `9` (Trail Difficulty Score, 1–10) |
| `distance_km` | `3.5` |
| `elevation_gain_m` | `226` |
| `elevation_density` | `64.0` (m gained per km) |
| `effort_descriptor` | `"Sustained Ascent"` |
| `grade_display` | `"Class A · 9/10 — Sustained Ascent"` |

**Resolved 2026-04-27:** `loadRMMRoutes()` now copies these fields from `crs.properties` into each Feature's `properties` at load time. No GeoJSON file edits required.

---
