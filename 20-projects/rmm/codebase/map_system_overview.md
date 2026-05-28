---
title: map_system_overview
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-27
updated_by: claude_cowork
tags: [codebase, map, mapbox, initialisation, filter-sidebar]
retrieval_priority: high
supersedes: ""
related: ["[[map_system_terrain_layers]]", "[[map_system_markers_and_interactions]]", "[[website_architecture]]", "[[base_map_visual_design]]", "[[map_build_sequence]]", "[[website_key_files]]", "[[poi_system_reference]]"]
---

# Map System — Initialisation, Configuration, Layers

The map is the primary product of the RMM platform. This document covers every layer, system, and behaviour in [scripts/map.js](scripts/map.js) at implementation level. Read this before touching any map code.

---

## 1. Initialisation

### Entry Points

The map module exposes a single public API:

```javascript
window.RMMMap = {
    init: function(containerId) { ... }
};
```

On the `/map` page, it auto-initialises via a `DOMContentLoaded` listener that checks for `#map-container` and also calls `initEmailOverlay()`. On `/dashboard`, an inline `<script>` calls `window.RMMMap.init('dashboard-map')` after DOMContentLoaded.

**Full-page mode** (`pages/map.html`): container is `<div id="map-container">` — styled in [styles/map.css](styles/map.css) as `position: fixed; top: var(--nav-height, 64px); left: 0; right: 0; bottom: 0`.

**Panel-embed mode** (`pages/dashboard.html`): container is `<div id="dashboard-map" class="map-panel-embed">` — styled as `position: relative; width: 100%; height: 100%`. The `window.addEventListener('resize', map.resize)` handler is wired in both modes so the panel reflows correctly.

### Initialisation Sequence

```
initMap(containerId)
  │
  ├─ 1. GET /api/config
  │       → receives: { token, styleUrl, trailsTilesetId, contoursTilesetId }
  │
  ├─ 2. mapboxgl.accessToken = config.token
  │
  ├─ 3. new mapboxgl.Map({ container, style, center, zoom, pitch, bearing, antialias: true })
  │       → uses DEFAULTS for camera; style URL from config
  │
  ├─ 4. map.addControl(NavigationControl, 'top-right')
  │
  └─ 5. map.on('load', async function() {
              │
              ├─ a. map.setFog({ ... })
              │
              ├─ b. await loadAllMarkerIcons()
              │       → fetches all SVGs from /public/icons/, rasterises to canvas ImageData
              │       → registers with map.addImage()
              │
              ├─ c. await addDataLayers(config)
              │       → adds contour source + layer (if contoursTilesetId set)
              │       → adds trails source + 4 layers (if trailsTilesetId set)
              │       → adds peaks GeoJSON source
              │       → adds caves GeoJSON source
              │       → try { await loadRMMRoutes() } catch — 8 GeoJSON fetches,
              │         merged, layered, single-trail starts on GL layer,
              │         shared-coord starts as DOM cluster Markers
              │       → addPeakLayers()
              │       → addCaveLayers()
              │       → setupHoverInteractions()
              │
              ├─ d. buildFilterSidebar()
              │       → injects toggle button (top-left) + collapsible left panel
              │       → wires toggle switches to map.setLayoutProperty() per layer group
              │       → must run after addDataLayers so all layer IDs exist
              │
              ├─ e. loadStyleConfig()
              │       → reads Supabase style_config (non-blocking)
              │       → calls map.easeTo() if camera overrides found
              │       → calls map.setTerrain() if terrain_exaggeration override found
              │
              └─ f. window.rmmMapReady = true
         })
```

If `/api/config` fails or returns no token/styleUrl, `showMapError(containerId)` renders a dark fallback state in the container div.

### Script Loading Order

In [pages/map.html](pages/map.html):
```html
<script src="https://api.mapbox.com/mapbox-gl-js/v3.3.0/mapbox-gl.js"></script>
<script src="/scripts/components.js"></script>
<script src="/scripts/map.js" defer></script>
```

`map.js` is `defer`-loaded — it runs after the DOM is parsed. In [pages/dashboard.html](pages/dashboard.html), `map.js` has no `defer` attribute, and the inline init script is at the bottom of `<body>`, making execution order explicit.

---


## 2. Map Configuration

### Default Camera (`DEFAULTS` object, top of map.js)

```javascript
const DEFAULTS = {
    center: [18.4241, -33.9249],  // Cape Peninsula geographic centre
    zoom: 10,
    pitch: 45,                     // 3D tilt — never set to 0
    bearing: 0,
    terrainExaggeration: 1.5
};
```

These are used at `mapboxgl.Map()` construction. They can be overridden post-load by the Supabase `style_config` table without a code deploy (see section 8).

### Fog

Set once in `map.on('load')`:

```javascript
map.setFog({
    range: [2, 12],
    color: '#171A14',
    'horizon-blend': 0.08,
    'high-color': '#1e2419',
    'space-color': '#0d0f0b',
    'star-intensity': 0.15
});
```

The fog parameters create the dark-olive atmospheric effect. `range: [2, 12]` means fog starts at 2× the camera distance and fully saturates at 12×. Star intensity at 0.15 gives a subtle starfield at high pitch.

### 3D Terrain

The terrain (`mapbox-dem` source and `terrain` setting) are **defined in the Mapbox Studio style JSON**, not in `map.js`. The only code interaction is:
- `DEFAULTS.terrainExaggeration` (1.5) applied in Studio
- `map.setTerrain({ source: 'mapbox-dem', exaggeration: float })` called in `loadStyleConfig()` if a Supabase override is present

This means changing the terrain DEM source or its base configuration requires a Mapbox Studio edit, not a code change.

### Mapbox GL JS Version

v3.3.0, loaded via CDN in both [pages/map.html](pages/map.html) and [pages/dashboard.html](pages/dashboard.html):
```html
<link href="https://api.mapbox.com/mapbox-gl-js/v3.3.0/mapbox-gl.css" rel="stylesheet">
<script src="https://api.mapbox.com/mapbox-gl-js/v3.3.0/mapbox-gl.js"></script>
```

---


## 3. Layer Architecture

All layers are added inside `addDataLayers(config)` after the style has loaded. Layer render order (bottom to top):

```
1. rmm-contours        (vector — conditional on CONTOURS_TILESET_ID)
2. rmm-trails-footway  (vector — conditional on TRAILS_TILESET_ID)
3. rmm-trails-steps    (vector — conditional on TRAILS_TILESET_ID)
4. rmm-trails-track    (vector — conditional on TRAILS_TILESET_ID)
5. rmm-trails-path     (vector — conditional on TRAILS_TILESET_ID)
6. rmm-routes          (GeoJSON — route base lines, line-opacity: 0, hidden by default)
7. rmm-routes-highlight(GeoJSON — revealed by filter to one named route on marker hover)
8. rmm-route-labels    (GeoJSON — route name labels, text-opacity: 0 by default)
9. rmm-route-starts    (GeoJSON — circles at single-trail starts only; clusters use DOM markers)
10. peaks              (GeoJSON — peak base markers T1/T2)
11. peaks-t3-hover     (GeoJSON — bespoke peak T3 icons, hidden by default)
12. caves              (GeoJSON — cave base markers T1/T2)
13. caves-t3-hover     (GeoJSON — bespoke cave T3 icons, hidden by default)
```

```
14. pois-[category]        (GeoJSON — per-category POI base markers T1/T2, ×14 categories)
15. pois-[category]-hover  (GeoJSON — per-category POI hover layer, ×14 categories)
```

Layers added later appear on top. The marker categories (peaks, caves, POIs) are always above route lines so features remain clickable even when visually overlapping.

**Cluster markers are not GL layers.** Trails that share a start coordinate (rounded to 5 dp) collapse to one DOM `mapboxgl.Marker` whose element is a `.rmm-cluster-primary-wrap > .rmm-cluster-primary` pair (wrap takes Mapbox's positional `translate`; inner takes our scale transforms). On hover or tap the primary fans out one `.rmm-cluster-secondary-wrap > .rmm-cluster-secondary` per trail. These markers live in the DOM above the GL canvas and are not part of the layer order above. See [[map_system_markers_and_interactions#11. Route Reveal & Cluster System]].

---


## 4. Filter Sidebar

**Added 2026-04-27.** A collapsible left sidebar panel that lets users toggle map layer groups on and off.

### UI Structure

- **Toggle button** (`.rmm-filter-toggle`): fixed top-left of map, below nav. Layers icon (SVG). Click opens/closes the panel.
- **Panel** (`.rmm-filter-panel`): 240px wide (220px on mobile), slides in from left via CSS `transform: translateX`. Dark theme matching brand (`#171A14` bg, `#2a2e24` borders).
- **Sections**: Markers, Routes, Trails, Overlays, Coming Soon — each with a section label and toggle rows.
- **Toggle switches**: CSS-only toggle (checkbox + styled track). Active state uses `#FF4E50` accent.

### Filter Groups (`FILTER_GROUPS` config object)

```javascript
var FILTER_GROUPS = {
    markers:  { items: [peaks, caves] },
    routes:   { items: [rmm-routes] },          // also toggles DOM cluster markers
    trails:   { items: [paths, tracks, footways, steps] },
    overlays: { items: [contours] },
    future:   { items: [events, pois, zones] }  // placeholder — toggles disabled
};
```

Each item maps a key to one or more GL layer IDs. When a toggle is flipped, `toggleFilterLayers()` calls `map.setLayoutProperty(layerId, 'visibility', 'visible'/'none')` for each associated layer.

### DOM Marker Handling

Route cluster markers (`.rmm-cluster-primary-wrap > .rmm-cluster-primary`, `.rmm-cluster-secondary-wrap > .rmm-cluster-secondary`) are DOM elements, not GL layers. Toggling routes off adds `.rmm-clusters-hidden` to `#map-container`, which hides them via CSS (`display: none !important`) — the rule targets both wrap and inner class names so it stays robust. Toggling routes off also calls `stopRoutePulse()` to clean up any active animation.

### Dismissal

Panel closes via: X button in header, Escape key, or clicking on the map. All three paths call `panel.classList.remove('open')`.

### State

All layers start visible. No persistence — filter state resets on page load. The `FILTER_GROUPS.future` items (Events, POIs, Zones) have `placeholder: true` — their checkboxes are disabled and greyed out, ready to wire up when those layer categories are implemented.

### Adding a New Toggleable Layer

1. Add the layer ID(s) to an existing group in `FILTER_GROUPS`, or create a new group
2. If the layer uses DOM markers (not GL layers), set `dom: 'clusters'` (or a new key) and add the corresponding CSS hide rule
3. If the layer doesn't exist yet, set `placeholder: true` until it's implemented

---


## 5. POI Layers (Added 2026-05-19)

POIs are fetched from the Supabase-backed API (`/api/python/pois?action=map-data`) and rendered as Mapbox GL layers. Unlike peaks and caves which use static GeoJSON files, POIs are API-served.

### Icon System

28 SVG icons total: 14 categories × 2 tiers (T1 at 24px, T2 at 32px). Stored in `/public/icons/pois/`. Naming: `t1-poi-[category-slug].svg` and `t2-poi-[category-slug].svg`.

All icons are loaded, rasterised to canvas ImageData, and registered with `map.addImage()` during `loadAllMarkerIcons()` — the same phase as peak and cave icons.

### Layer Structure

Each POI category gets two Mapbox layers:

- **Base layer** (`pois-[category]`): Shows T1 icon below zoom 13, T2 at zoom 13+. Filter: `['==', ['get', 'category'], 'category_key']`.
- **Hover layer** (`pois-[category]-hover`): Hidden by default. Shown on mouseenter for interaction feedback.

All category layers share a single GeoJSON source (`pois-source`) loaded from the API response.

### Categories

waterfall, stream_crossing, info_board, viewpoint, parking, gate, water_source, danger, rest_area, bridge, rock_formation, shelter, trailhead, photo_spot.

### Filter Sidebar Integration

POI layers are toggled as a group. The filter sidebar's "POIs" toggle calls `map.setLayoutProperty()` on all POI category layers.

---

## 6. Route Popup System (Updated 2026-05-19)

Route popups appear when a user hovers over a route start marker (single-trail) or clicks a cluster secondary marker. The popup shows: route name, grade badge (colour-coded A–F), TDS score, event type label, distance, elevation gain, surface breakdown (road %), and a "View trail details →" link to `/trail/:slug`.

### Event Type Labels

```javascript
var _eventLabels = {
    'trail': 'Trail Run', 'time_trial': 'Time Trial',
    'hill_climb': 'Hill Climb', 'hill_bomb': 'Hill Bomb'
};
```

The `_eventLabel(t)` helper maps DB event type strings to display labels.

### Popup Linger System (350ms delay)

To prevent the popup from disappearing before users can click the trail detail link, a 350ms linger delay was added:

1. On `mouseleave` from the route marker, `dismissRoutePopup()` starts a 350ms `setTimeout` before removing the popup.
2. If the user's mouse enters the popup element within 350ms, the timer is cancelled and the popup stays open.
3. When the mouse leaves the popup element, the dismiss timer restarts.
4. If a new marker `mouseenter` fires, any pending dismiss timer is cancelled immediately.

**Key variables:**
- `_routePopupTimer` — holds the setTimeout ID for pending dismissal
- `dismissRoutePopup()` — starts the 350ms delay
- Popup `mouseenter`/`mouseleave` handlers — wired via `routePopup.on('open', ...)`

---

## 12. Camera and Viewport

### Initial Camera

Set at `mapboxgl.Map()` construction from `DEFAULTS`:

```javascript
center: [18.4241, -33.9249]  // Cape Peninsula geographic centre
zoom: 10
pitch: 45                     // 3D perspective — locked by architecture rule
bearing: 0
antialias: true               // smooth edges on 3D geometry
```

### Post-Load Camera Adjustments

`loadStyleConfig()` fires after all layers are added. If Supabase `style_config` contains camera keys, it calls:

```javascript
map.easeTo({
    center: [...],     // if map_center_lng + map_center_lat present
    zoom: ...,         // if map_zoom present
    pitch: ...,        // if map_pitch present
    bearing: ...,      // if map_bearing present
    duration: 1500,    // 1.5 second smooth transition
    essential: true    // transition is not skipped by reduced-motion preferences
});
```

This runs after the map has loaded and rendered, so users see the default view for ~1–2 seconds before the configured view eases in.

### Intro Animation

**Not yet implemented.** Stage 4 of the map build plan includes a fly-in intro animation. When built, it will be a `map.flyTo()` or choreographed `map.easeTo()` sequence called from within `map.on('load')` after layers are added. No animation code exists yet.

### Panel Embed Resize

In panel-embed mode (dashboard), `window.addEventListener('resize', map.resize)` is wired in `initMap()`. This ensures the GL canvas redraws to fill its container when the browser window resizes.

---


## 14. Token Delivery

The Mapbox access token never appears in source code. At map init:

1. `initMap()` calls `fetch('/api/config')`
2. [api/config.js](api/config.js) reads `process.env.MAPBOX_PUBLIC_TOKEN` and returns it as JSON
3. `mapboxgl.accessToken = config.token` is set immediately before `new mapboxgl.Map()`

If the fetch fails or the response is malformed, `showMapError()` renders a fallback state. The token is set once per map init — it is not stored in `localStorage` or any persistent state.

### CORS restriction on `/api/config`

The endpoint only sets the `Access-Control-Allow-Origin` header for:
- `https://runmadmaps.com`
- `http://localhost:3000`

Other origins receive the JSON without the CORS header, which means cross-origin fetch from a different domain would fail. This is intentional — it prevents the token from being trivially harvested from other sites that embed a `fetch('/api/config')` call.

---


## 15. Performance Patterns

### Icon Loading: Deduplication

`loadAllMarkerIcons()` tracks loaded icons by `mapId` in a `loaded` object. If two features share the same SVG (e.g. both Boomslang Cave entrances share `cave-boomslang-cave-t3`), the SVG is fetched and rasterised only once. `map.hasImage(iconId)` is also checked before calling `map.addImage()` to prevent duplicate registration errors if `loadAllMarkerIcons()` were called twice.

### Routes: Sequential Fetch

Route files are loaded with a `for` loop and `await` — sequential, not parallel. This was chosen to avoid overwhelming the browser with 8 simultaneous fetches. The total payload is ~160KB of GeoJSON. A parallel `Promise.all` approach would be marginally faster but is not needed at current scale.

### Popup Reuse

A single `mapboxgl.Popup` instance is created once and reused via `setLngLat().setHTML().addTo(map)`. Creating a new popup per hover event would cause memory growth and visible flicker. `.remove()` on `mouseleave` detaches it from the map without destroying the instance.

### Coordinate Storage

`window._rmmRouteCoords` stores the full GPS coordinate arrays at load time. This avoids calling `map.querySourceFeatures()` on hover — which only returns tile-clipped coordinates and has a performance cost. The trade-off is ~160KB of coordinate data held in memory; acceptable at current route count.

### No Clustering

Peak and cave markers use no clustering. At zoom 10 (the default view), the peninsula is spread across a wide area and marker density is low. Clustering would add complexity with no visible benefit at current data volume (65 peaks, ~35 named caves).

### No Lazy Loading

All data (peaks, caves, 8 route files) is loaded on map init. There is no viewport-based or on-demand loading. At current data volume this is appropriate — all files combined are under 200KB.

---


## 16. Global State Exposed by map.js

| Variable | Type | Purpose |
|---|---|---|
| `window.RMMMap` | object | Public API — `{ init(containerId) }` |
| `window._rmmRouteCoords` | object | `{ routeName: [[lng,lat,ele], ...] }` — used by pulse animation |
| `window.rmmMapReady` | `true` / undefined | Set after full layer init; can be polled by external code |

Module-level variables (not window-scoped):

| Variable | Type | Purpose |
|---|---|---|
| `map` | `mapboxgl.Map` | The active map instance |
| `pulseAnimation` | `setTimeout` ID | Active pulse animation tick |
| `pulseMarker` | `mapboxgl.Marker` | The active pulse dot marker |
| `FILTER_GROUPS` | object | Layer toggle config — maps filter keys to GL layer IDs, used by `buildFilterSidebar()` |
| `_routePopupTimer` | `setTimeout` ID / null | Pending 350ms popup dismiss timer |
| `_eventLabels` | object | Maps DB event type strings to display labels |
| `routePopup` | `mapboxgl.Popup` | Reusable popup for route hover/click interactions |
