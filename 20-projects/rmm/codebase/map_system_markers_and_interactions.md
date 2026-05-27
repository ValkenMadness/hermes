---
title: map_system_markers_and_interactions
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-21
updated_by: claude_cowork
tags: [codebase, map, markers, interactions]
supersedes: ""
related: ["[[map_system_overview]]", "[[map_system_terrain_layers]]", "[[marker_render_states]]", "[[peak_tier_system]]", "[[poi_system_reference]]"]
---

# Map System — Markers, Popups, Interactions

The map is the primary product of the RMM platform. This document covers every layer, system, and behaviour in [scripts/map.js](scripts/map.js) at implementation level. Read this before touching any map code.

---

## 7. Marker System

### Architecture Overview

The marker system uses a two-layer-per-category pattern:

1. **Base layer** — always visible from zoom 8; renders T1 icons at zoom < 13, T2 icons at zoom ≥ 13 using a `step` expression
2. **T3 hover layer** — hidden by default (filter matches no features); revealed for a specific feature name on `mouseenter` or tap

This avoids creating one layer per marker or per icon state. Adding a new bespoke icon only requires a config entry in `MARKER_STYLES` — no new layer code.

### `MARKER_STYLES` Config Object

```javascript
var MARKER_STYLES = {
    peaks: {
        source: 'peaks',
        icons: {
            t1: { file: '/public/icons/peaks/t1-peak-generic.svg', size: 24, mapId: 'peak-t1' },
            t2: { file: '/public/icons/peaks/t2-peak-generic.svg', size: 32, mapId: 'peak-t2' }
        },
        bespoke: {
            "Maclear's Beacon": {
                t3: { file: '/public/icons/peaks/t3-peak-maclears-beacon.svg', size: 48, mapId: 'peak-maclears-beacon-t3' }
            }
        },
        iconSwitch: 13,
        filter: null,
        layerId: 'peaks',
        hoverLayerId: 'peaks-t3-hover'
    },
    caves: {
        source: 'caves',
        icons: {
            t1: { file: '/public/icons/caves/t1-cave-generic.svg', size: 24, mapId: 'cave-t1' },
            t2: { file: '/public/icons/caves/t2-cave-generic.svg', size: 32, mapId: 'cave-t2' }
        },
        bespoke: {
            'Boomslang Cave North Entrance': {
                t3: { file: '/public/icons/caves/t3-cave-boomslang-cave.svg', size: 48, mapId: 'cave-boomslang-cave-t3' }
            },
            'Boomslang Cave South Entrance': {
                t3: { file: '/public/icons/caves/t3-cave-boomslang-cave.svg', size: 48, mapId: 'cave-boomslang-cave-t3' }
            }
        },
        iconSwitch: 13,
        filter: ['has', 'name'],
        layerId: 'caves',
        hoverLayerId: 'caves-t3-hover'
    }
};
```

Note: Both Boomslang Cave entrances share the same icon file and `mapId` — `loadAllMarkerIcons()` deduplicates by `mapId` so it is loaded only once.

### Icon Loading (`loadSVGAsMapIcon`)

SVG icons cannot be passed directly to `map.addImage()`. The loading pipeline:

1. `fetch(url)` → response text (raw SVG markup)
2. `new Blob([svgText], { type: 'image/svg+xml' })` → `URL.createObjectURL(blob)` → blob URL
3. `new Image()` → `img.src = blobUrl`
4. On `img.onload`: create off-screen `<canvas>` at `size × size` pixels
5. `ctx.drawImage(img, 0, 0, size, size)`
6. `map.addImage(iconId, ctx.getImageData(0, 0, size, size))`
7. `URL.revokeObjectURL(blobUrl)` — memory cleanup

The blob URL workaround avoids CORS restrictions that occur when drawing an `<img src="...svg">` directly to canvas from a different origin. All icon sizes are square (`size × size`).

`loadAllMarkerIcons()` calls this for every icon in `MARKER_STYLES` (generic T1/T2 + all bespoke T3 entries), deduplicates by `mapId`, and returns `Promise.all()`. The next step in the init sequence (`addDataLayers`) only runs after all icons are registered.

### Peak Layer Details (`addPeakLayers`)

**Base layer (`'peaks'`), minzoom 8:**

| Property | Expression |
|---|---|
| Icon image | `step(zoom, 'peak-t1', 13, 'peak-t2')` — T1 below zoom 13, T2 at or above |
| Icon size | Interpolated: 0.55 at z8, 0.66 at z10, 0.77 at z12, 0.66 at z13, 0.77 at z15, 0.55 at z18 |
| Icon allow overlap | `step(zoom, false, 13, true)` — markers overlap only at zoom 13+ |
| Text field | `step(zoom, '', 13, name)` — labels appear at zoom 13 |
| Text offset | `[0, 1.2]` em units (below icon) |
| Text size | Interpolated: 10px at z13, 12px at z15 |
| Text font | Space Mono Regular → DIN Pro Regular → Arial Unicode MS Regular |
| Text color | `#171A14` (dark olive) |
| Text halo | `#F5ECD7` (warm white), width 2 |
| Text optional | `true` — labels drop if they cause overlap |

**T3 hover layer (`'peaks-t3-hover'`):**
- Default filter: `['==', ['get', 'name'], '']` — matches no feature (effectively invisible)
- Icon image: `buildBespokeMatchExpr('peaks')` — a GL `match` expression: `match(name, "Maclear's Beacon", 'peak-maclears-beacon-t3', '')`. The empty string fallback renders nothing for non-bespoke features.
- Icon size: `1.1` (fixed — the SVG is already the target size)
- `icon-allow-overlap: true` — T3 always visible when active
- Text size: 13px (slightly larger than base)
- Text offset: `[0, 1.8]` (further below the larger icon)

### Cave Layer Details (`addCaveLayers`)

Same two-layer pattern as peaks. Key differences:
- Filter on base layer: `['has', 'name']` — unnamed cave entrances (where `name: null`) are not rendered
- Icon sizes (raw canvas sizes): T1 = 24px, T2 = 32px — same as peaks
- `icon-size` interpolation values are smaller (0.375 → 0.525 range) — caves render at ~75% the visual weight of peaks
- T3 hover layer icon-size: `0.75` (fixed)

---


## 8. Hover Interactions (`setupHoverInteractions`)

Runs for every category in `MARKER_STYLES`. For each category that has at least one bespoke T3 entry:

### Desktop (mouse)

**`mouseenter` on base layer:**
1. Get `features[0].properties.name`
2. If name is in `bespokeNames` list:
   - Set cursor to `'pointer'`
   - Set T3 hover layer filter to `['==', ['get', 'name'], name]` — shows T3 icon for this feature
   - Set base layer filter to exclude this name (hides T1/T2 for the feature so icons don't stack)

**`mouseleave` on base layer:**
1. Reset cursor to `''`
2. Reset T3 hover layer filter to `['==', ['get', 'name'], '']` (hides T3)
3. Reset base layer filter to `cat.filter` (original filter, or `null` for peaks)

**`mouseenter`/`mouseleave` on T3 hover layer:** keeps cursor as pointer during the transition from base → hover layer, preventing a flicker where the cursor resets for a single frame.

### Mobile (touch)

**`click` on base layer:**
1. If bespoke: show T3 icon (same filter logic as desktop mouseenter)
2. `setTimeout(revert, 3000)` — icon returns to T1/T2 after 3 seconds

---


## 8b. POI Marker Layers (Added 2026-05-19)

POI markers follow the same two-layer-per-category pattern as peaks and caves, but with two key differences:

1. **API-served data** — POIs are fetched from `/api/python/pois?action=map-data` (Supabase) rather than static GeoJSON files.
2. **No bespoke T3 tier** — POIs use T1 (24px) and T2 (32px) only. No per-POI custom icons.

### Layer Structure

Each of the 14 POI categories gets two Mapbox layers:
- `pois-[category]` — base layer with T1→T2 icon swap at zoom 13
- `pois-[category]-hover` — hidden by default, shown on mouseenter

All layers share a single GeoJSON source (`pois-source`), filtered by `['==', ['get', 'category'], 'category_key']`.

### Icon Loading

28 SVG icons (14 categories × T1 + T2) are loaded during `loadAllMarkerIcons()` alongside peak and cave icons. Icon naming: `t1-poi-[slug].svg` and `t2-poi-[slug].svg` in `/public/icons/pois/`. The category slug uses hyphens in filenames (e.g. `stream_crossing` → `stream-crossing`).

### Hover Interactions

POI hover follows a simplified version of the peak/cave pattern — no T3 bespoke icons, just cursor change and a popup showing the POI name and category label.

### Filter Sidebar

POI layers are toggled as a single group. The filter sidebar "POIs" toggle replaced the placeholder that existed previously.

### Adding a New POI Category

1. Create `t1-poi-[slug].svg` and `t2-poi-[slug].svg` in `/public/icons/pois/`
2. Add the category to `POI_CATEGORIES` in `poi-manager.js` and `trail-detail.js`
3. Add icon entries to the POI icon loading array in `map.js`
4. No backend changes needed — the API accepts any category string

See [[poi_system_reference]] for full POI system documentation.

---

## 9. Popup System

Only one popup exists: the **route info popup** (`routePopup`). There is currently no popup for peaks or caves.

### Route Popup

```javascript
var routePopup = new mapboxgl.Popup({
    closeButton: false,
    closeOnClick: false,
    className: 'rmm-route-popup',
    maxWidth: '280px',
    offset: 15
});
```

- Created once inside `loadRMMRoutes()`, reused across all route interactions
- `closeButton: false` — no X button; dismissal is implicit on `mouseleave`
- `closeOnClick: false` — clicking the map doesn't dismiss it

**Trigger:** `mouseenter` on the `rmm-route-starts` GL layer — and only single-trail start circles render in that layer. The line layers are not hoverable: `rmm-routes` is `line-opacity: 0` and only revealed via filter on the `rmm-routes-highlight` layer when a marker is hovered.

**Cluster parity (resolved 2026-04-27, refined 2026-04-30):** Cluster secondary markers have full popup parity — each secondary's `mouseenter` builds and opens the same route popup with grade, distance, elevation gain, and elevation density stats. Cluster popup behaviour differs from single-trail starts in two important ways:

- The popup is **anchored to the parent's lngLat** (not the hovered child's), so it always hangs centrally beneath the whole parent-child device regardless of which child is hovered. This guarantees it never overlaps the trail highlight or the fanned children.
- The anchor is **always `'top'`** (popup body extends below) rather than the trail-aware anchor used for single starts. An edge fallback flips to `'bottom'` (popup floats above) when the parent is within ~160 px of the bottom of the map viewport, so the card isn't clipped.

Single-trail starts continue to use `getPopupAnchorAwayFromTrail()` — the trail-aware anchor only applies when there's a single trail to sample.

**Content (updated 2026-05-19):** HTML string built from Feature properties. Two popup locations (single-trail start mouseenter and cluster secondary mouseenter) both render identical content:

- Grade badge (colour-coded A–F)
- Trail name
- Stats row: distance, elevation gain, elevation density
- Event type label (via `_eventLabel()` helper: trail → Trail Run, time_trial → Time Trial, etc.)
- Road percentage (shown only if > 0%)
- "View trail details →" link to `/trail/:slug`

The old "Route details coming soon" placeholder has been replaced with a live link.

**Data merge (fixed 2026-04-27):** `loadRMMRoutes()` now merges `crs.properties` fields into each Feature's `properties` at load time. The `name` field is copied as `display_name` to avoid overwriting the Feature's existing `name`. All other fields (`grade`, `tds`, `distance_km`, `elevation_gain_m`, `elevation_density`, `grade_display`, `effort_descriptor`) are copied only if absent from the Feature. No GeoJSON files were edited.

**Styling** ([styles/map.css](styles/map.css)):
- `.rmm-route-popup .mapboxgl-popup-content` — dark olive background (`#171A14`), red-tinted border, 8px radius, box-shadow
- `.rmm-route-popup .mapboxgl-popup-tip` — tip arrow coloured to match background
- `.rmm-route-card-grade` — `#FF4E50`, 11px, uppercase letter-spacing
- `.rmm-route-card-name` — white, 14px bold
- `.rmm-route-card-stats` — flex row, warm white (`#F5ECD7`), 11px, separated by border-bottom
- `.rmm-route-card-action` — muted small text placeholder

**Dismiss (updated 2026-05-19 — linger system):** `mouseleave` on `rmm-route-starts` calls `dismissRoutePopup()` which starts a 350ms `setTimeout` before removing the popup. If the user's mouse enters the popup element within 350ms, the timer is cancelled and the popup stays open. When the mouse leaves the popup, the dismiss timer restarts. If a new marker `mouseenter` fires, any pending dismiss timer is cancelled immediately. This allows users to hover over the popup and click the "View trail details" link.

Key state: `_routePopupTimer` (setTimeout ID or null). Popup `mouseenter`/`mouseleave` handlers are wired via `routePopup.on('open', ...)`.

---


## 10. Route Pulse Animation

A red glowing dot that traverses a route's coordinates when the route is hovered.

### Implementation

```javascript
var pulseAnimation = null;   // setTimeout reference
var pulseMarker = null;      // mapboxgl.Marker reference

function startRoutePulse(coords) {
    stopRoutePulse();  // cancel any running pulse first
    var el = document.createElement('div');
    el.className = 'rmm-pulse-dot';
    pulseMarker = new mapboxgl.Marker({ element: el, anchor: 'center' })
        .setLngLat([coords[0][0], coords[0][1]])
        .addTo(map);

    var index = 0;
    var total = coords.length;
    var PX_PER_MS = 0.08;  // ~80 pixels per second visual speed

    function step() {
        if (index >= total) { index = 0; }
        var c = coords[index];
        pulseMarker.setLngLat([c[0], c[1]]);

        var next = (index + 1) % total;
        var nc = coords[next];
        var cp = map.project([c[0], c[1]]);
        var np = map.project([nc[0], nc[1]]);
        var dist = Math.sqrt((np.x - cp.x) * (np.x - cp.x) + (np.y - cp.y) * (np.y - cp.y));
        var delay = Math.max(16, Math.round(dist / PX_PER_MS));

        index++;
        pulseAnimation = setTimeout(step, delay);
    }
    step();
}
```

Speed calculation (updated 2026-04-27): delay is now calculated per-step from the screen-space pixel distance between consecutive coordinates. `PX_PER_MS = 0.08` yields ~80 pixels/second visual speed. This is **zoom-independent** — the dot moves at a constant visual pace regardless of zoom level. Previously used a fixed `3000/total` interval which made the animation appear faster when zoomed in.

**Trigger:** Starts on `mouseenter` of `rmm-route-starts` (single-trail starts) and on `mouseenter` of cluster secondaries. Stops on `mouseleave` of either. The `rmm-routes` line layer is no longer hoverable since base opacity is 0.

**Coordinate source:** `window._rmmRouteCoords[routeName]` — the full unclipped coordinate array stored at load time. Mapbox's `querySourceFeatures()` would return tile-clipped partial arrays; using the stored arrays ensures the dot traverses the complete route.

**Visual** ([styles/map.css](styles/map.css) — `.rmm-pulse-dot`):
- 10×10px red circle (`#FF4E50`)
- Double box-shadow glow: `0 0 12px 4px rgba(255,78,80,0.6)` inner + `0 0 24px 8px rgba(255,78,80,0.3)` outer
- `pointer-events: none` — the dot doesn't interfere with map interaction

---


## 11. Route Reveal & Cluster System

**Status:** Added 2026-04-25. Replaces the previous always-visible-line behaviour with a hover-to-reveal pattern.

### Behaviour summary

- All graded route lines are hidden by default (`rmm-routes` paint `line-opacity: 0`).
- A second line layer `rmm-routes-highlight` (`line-opacity: 0.5`, slightly wider, same `#FF4E50` colour) is filtered to a single named route on hover.
- A third symbol layer `rmm-route-labels` is hidden via `text-opacity: 0` until a route is highlighted, at which point a `case` expression sets opacity to 1 for the matching route only.
- Reveal is driven from marker hover — never from line hover.

The two helpers are scoped inside `loadRMMRoutes()`:

```javascript
function highlightRoute(name) {
    map.setFilter('rmm-routes-highlight', ['==', ['get', 'name'], name]);
    map.setPaintProperty('rmm-route-labels', 'text-opacity',
        ['case', ['==', ['get', 'name'], name], 1.0, 0]
    );
}
function clearHighlight() {
    map.setFilter('rmm-routes-highlight', ['==', ['get', 'name'], '']);
    map.setPaintProperty('rmm-route-labels', 'text-opacity', 0);
}
```

These two functions are the contract every marker hover hook calls into. Their interface is stable — swap circle markers for custom artwork without touching them.

### Start-point pre-processing

`loadRMMRoutes()` builds `startFeatures` from each route's first coordinate, then groups by rounded coordinate (5 dp ≈ 1 m precision) into `coordGroups`:

- **Singletons** → kept in `singleFeatures`, fed to the `rmm-route-starts` GL circle layer (existing behaviour).
- **Groups of 2+** → become `clusterGroups`, each rendered as one DOM `mapboxgl.Marker` with class `.rmm-cluster-primary`.

This split means `rmm-route-starts` no longer contains stacked markers — each cluster collapses to one primary marker that fans out on hover.

### Geometry normalisation (LineString + MultiLineString)

The route GeoJSON files use `MultiLineString` geometry, where coordinates are nested 3 levels (`[[[lng,lat,ele], ...]]`). Two helpers handle both geometry types:

```javascript
function flattenLineCoords(geom) {
    if (geom.type === 'LineString')      return geom.coordinates;
    if (geom.type === 'MultiLineString') return [].concat.apply([], geom.coordinates);
    return null;
}
function getFirstPoint(geom) {
    var flat = flattenLineCoords(geom);
    if (!flat || !flat.length) return null;
    var p = flat[0];
    return (p && p.length >= 2) ? [p[0], p[1]] : null;
}
```

`getFirstPoint` is used to position start markers; `flattenLineCoords` is used to populate `window._rmmRouteCoords` for the pulse animation.

### Cluster fan-out interaction

State is closure-scoped inside `loadRMMRoutes()`, so only one cluster can be open at a time:

```javascript
var clusterCollapseTimer = null;   // setTimeout for debounced collapse
var clusterSecondaries = [];       // active mapboxgl.Marker instances
var clusterBridgeEl = null;        // invisible SVG hit area, primary → children
var clusterPrimaryWrap = null;     // wrap of the currently-expanded primary (carries .is-expanded)
```

#### DOM structure (wrap / inner)

Each cluster marker is a two-element structure:

- `.rmm-cluster-primary-wrap` (or `-secondary-wrap`) — Mapbox positions this via inline `transform: translate(...)`. Sized 18×18 (matching the inner's natural visible diameter) so flex doesn't shrink it.
- `.rmm-cluster-primary` (or `-secondary`) — the visible circle, 14 content + 2px border each side, content-box. We CSS-transform this for hover and zoom-scale effects.

The wrap/inner split is required because Mapbox writes inline `transform: translate(...)` on the marker element. If we transformed the same element for the parent shrink animation we'd overwrite the position.

#### Primary `mouseenter` / `click`

Cancels any pending collapse, calls `expandCluster(lngLat, trails, primaryWrap)`. The third arg is the wrap element so `expandCluster` can tag it with `.is-expanded` for the CSS shrink. Click is also wired (no-op on desktop where mouseenter has already fired; the entry point on touch devices).

#### `expandCluster(lngLat, trails, primaryWrap)`

1. Adds `.is-expanded` to the primary wrap → CSS scales its inner to 70% via `scale(calc(var(--rmm-cluster-scale, 1) * 0.7))`.
2. Projects the primary lngLat to pixel space.
3. Places one secondary marker per trail at a fixed pixel-space radius (26 px) fanned starting from **9 o'clock and going clockwise around the parent**. Arc math:

   ```
   startAngle = π          // 9 o'clock in screen coords (y-down)
   FIXED_GAP  = 40°        // ≈ 0.698 rad — ~3.8 px clearance between 14 px markers at r=26
   FULL_CIRCLE_THRESHOLD = 9
   step       = (n > THRESHOLD) ? (2π / n) : FIXED_GAP
   angleᵢ     = startAngle + i · step       // angle increases ⇒ visually CW
   ```

   For ≤9 children the fan sits tight in the upper arc starting at 9 o'clock — children never land on opposite ends of the parent. For >9 children the step falls back to even spacing around a full circle so children don't overshoot 360°.
4. Each secondary is a `wrap > inner` pair with class `.rmm-cluster-secondary-wrap` / `.rmm-cluster-secondary`. The inner gets a staggered `animation-delay` (`i * 30ms`) for the fan-in keyframes.
5. Each wrap fires `mouseenter` → `cancelCollapse()` + `highlightRoute()` + popup + pulse, `mouseleave` → `routePopup.remove()` + `clearHighlight()` + `stopRoutePulse()` + `scheduleCollapse()`, and `click` → same as `mouseenter` (touch entry point).
6. Calls `createBridge(center, childPixels)` to lay down the invisible SVG hit-bridge.

Pixel-space positioning means the fan keeps the same visual size at every zoom level (independent of the per-marker zoom scale described below).

#### Zoom-scale parity with GL singletons

GL `rmm-route-starts` interpolates `circle-radius` 3 → 5 → 7 across zooms 8 → 12 → 15 with a 2 px stroke (drawn outside the radius). Visible diameter therefore steps 10 → 14 → 18 px. The DOM cluster primary's natural visible diameter is 18 (14 content + 2px border each side), so without compensation it would look noticeably bigger than the singletons at low/mid zoom.

`computeClusterPrimaryScale(zoom)` mirrors that interpolation and `syncClusterScale()` writes the result to `--rmm-cluster-scale` on `<html>`. The CSS rules for `.rmm-cluster-primary`, `.rmm-cluster-secondary`, and the `is-expanded` and fan-in keyframes all consume that variable so cluster markers stay pixel-matched to the GL singletons at every zoom.

```javascript
syncClusterScale();                  // initial value
map.on('zoom', syncClusterScale);    // re-sync as the user zooms
```

#### SVG hover bridge (`createBridge`)

An invisible SVG polygon is positioned over the gap between the primary and all child markers. This prevents the fan from collapsing when the mouse traverses between primary and secondaries. The bridge is removed on collapse.

#### `scheduleCollapse` / `cancelCollapse`

350 ms debounce on the primary's `mouseleave` so the cursor can cross the gap between primary and secondary without collapsing the fan. Any secondary's `mouseenter` cancels the pending collapse.

#### `collapseCluster`

Removes all secondary markers, the SVG bridge, strips `.is-expanded` from the active primary wrap (and any stale wraps as a defensive sweep), clears the route highlight, stops pulse, and removes the popup.

#### Mobile / touch handling (added 2026-04-30)

DOM markers don't receive Mapbox `click` events on the GL canvas, so the touch path needs explicit wiring:

- **Tap on primary** → `expandCluster(...)` (the click handler is a no-op on desktop where mouseenter has already opened the fan).
- **Tap on secondary** → same handler as `mouseenter` (highlight + popup + pulse).
- **Tap on the map canvas, not on a cluster element** → `collapseCluster()`. Wired via `map.on('click', ...)` with a `target.closest('.rmm-cluster-primary-wrap, .rmm-cluster-secondary-wrap')` guard.
- **Map pan or zoom (`movestart`)** → `collapseCluster()`. The fan is positioned in pixel space, so it would visually drift away from the parent during a drag if we kept it open.

#### Animation and reduced motion

- Primary shrink: `transform` transitions over 240 ms with `cubic-bezier(0.4, 0, 0.2, 1)`.
- Secondary fan-in: `rmm-cluster-secondary-in` keyframes (220 ms, `cubic-bezier(0.34, 1.56, 0.64, 1)`) with a 30 ms-per-index stagger. Keyframes multiply by `--rmm-cluster-scale` so the entrance lands on the correct steady-state size at any zoom.
- `@media (prefers-reduced-motion: reduce)` disables the primary transition and the secondary animation. Geometry still works, just without the bouncy entrance.

### Cluster vs single-trail behaviour parity

| Behaviour | Single-trail start (`rmm-route-starts`) | Cluster secondary (`.rmm-cluster-secondary`) |
|---|---|---|
| Reveal trail line on hover | Yes (`highlightRoute`) | Yes (`highlightRoute`) |
| Show route label | Yes | Yes |
| Pulse animation along route | Yes (`startRoutePulse`) | Yes (added 2026-04-27) |
| Open route info popup | Yes | Yes (added 2026-04-27) |
| Popup anchor | Trail-aware (`getPopupAnchorAwayFromTrail`) | Always `'top'` (popup hangs below the cluster), with edge-fallback flip to `'bottom'` near the bottom of the viewport |
| Popup attaches to | Single start lngLat | **Parent** lngLat (not the hovered child) — popup hangs centrally beneath the whole device |
| Zoom-scale parity | Native (GL `circle-radius` interpolation) | Via `--rmm-cluster-scale` CSS variable, recomputed on `map.on('zoom')` (added 2026-04-30) |
| Mobile tap support | Native pointer events on canvas | DOM `click` on primary expands; `click` on secondary selects; canvas tap or `movestart` collapses (added 2026-04-30) |

### Defensive isolation in `addDataLayers`

`await loadRMMRoutes()` is wrapped in `try/catch` inside `addDataLayers()`. A throw inside route loading no longer aborts the rest of the load, so peak and cave layers always render even if a future route-loading change breaks. Any caught error is logged as `RMM: loadRMMRoutes failed —`.

This was added after the MultiLineString crash (2026-04-25) — see [[website_build_status_issues#Recently Fixed]].

---


## 13. Admin-Configurable Elements (Supabase)

All dynamic configuration that can change without a code deploy is stored in the Supabase `style_config` table and read by `loadStyleConfig()`.

### How it works

```javascript
fetch(SUPABASE_URL + '/rest/v1/style_config?select=key,value', {
    headers: { 'apikey': SUPABASE_ANON_KEY, 'Content-Type': 'application/json' }
})
```

Returns an array of `{ key, value }` rows. The function builds a `config` object and applies any matching keys.

### Supported Keys

| Key | Applied to | Effect |
|---|---|---|
| `map_center_lng` | `map.easeTo()` | Overrides default longitude (use with `map_center_lat`) |
| `map_center_lat` | `map.easeTo()` | Overrides default latitude (use with `map_center_lng`) |
| `map_zoom` | `map.easeTo()` | Overrides default zoom level |
| `map_pitch` | `map.easeTo()` | Overrides camera pitch |
| `map_bearing` | `map.easeTo()` | Overrides camera bearing |
| `terrain_exaggeration` | `map.setTerrain()` | Overrides 3D terrain height multiplier |

Unrecognised keys are silently ignored. Missing keys leave `DEFAULTS` in place. If Supabase is unreachable, all errors are caught and the map continues with defaults — the `style_config` load is entirely non-blocking.

### Adding a New Config Key

In `loadStyleConfig()` within [scripts/map.js](scripts/map.js), add a new `if (config.your_key)` block and apply the value via the relevant Mapbox GL method. Then add the key/value row to the Supabase `style_config` table.

---
