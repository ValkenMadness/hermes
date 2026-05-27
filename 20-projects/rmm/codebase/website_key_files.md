---
title: website_key_files
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-21
updated_by: claude_cowork
tags: [codebase, website, reference, key-files]
supersedes: ""
related: ["[[website_architecture]]", "[[website_component_map]]", "[[map_system_overview]]", "[[poi_system_reference]]", "[[trail_ecosystem_design]]"]
---

# RMM Website — Key Files Lookup

If you need to change X, edit these files. Nothing else. No guessing.

---

## Global Branding & Design System

| To change... | Edit these files |
|---|---|
| **Color palette** (all CSS variables: dark, light, accent, muted) | [styles/components.css](styles/components.css) — `:root` block at the top |
| **Typography / typeface** | [styles/components.css](styles/components.css) — `--font-mono` variable; also update the `<link>` in every HTML page's `<head>` |
| **Logo image** | [public/images/logo.svg](public/images/logo.svg) — replace file; filename referenced in [scripts/components.js](scripts/components.js) `renderNav()` and `renderFooter()` |
| **Favicon** | [public/images/favicon.png](public/images/favicon.png) — replace file; filename referenced in every `pages/*.html` `<head>` |
| **OG / social card image** | [public/images/og-image.png](public/images/og-image.png) — replace file; URL hardcoded in `<meta og:image>` tags in each `pages/*.html` |
| **OG title or description for a specific page** | The relevant `pages/*.html` — edit the `<meta property="og:title">` and `<meta property="og:description">` tags |
| **Page `<title>` tag** | The relevant `pages/*.html` — `<title>` in `<head>` |
| **Global nav height** | [styles/components.css](styles/components.css) — `--nav-height: 64px` |
| **Mobile layout breakpoints** | [styles/components.css](styles/components.css) — `@media` queries (768px tablet, 480px phone) |

---

## Navigation & Footer

| To change... | Edit these files |
|---|---|
| **Nav links** (add, remove, reorder) | [scripts/components.js](scripts/components.js) — `renderNav()` function |
| **Footer links** (add, remove, reorder) | [scripts/components.js](scripts/components.js) — `renderFooter()` function |
| **Legal links in footer** (Privacy, Terms, Cookies, Acceptable Use) | [scripts/components.js](scripts/components.js) — `renderFooter()` footer-legal-links section |
| **Footer tagline text** | [scripts/components.js](scripts/components.js) — `renderFooter()` `footer-tagline` paragraph |
| **Footer copyright text or location** | [scripts/components.js](scripts/components.js) — `renderFooter()` footer-legal section |
| **Which pages show a footer** | [scripts/components.js](scripts/components.js) — `DOMContentLoaded` block at the bottom; currently skipped on `/` and `/map` |
| **Admin-gated nav links** (which pages are hidden from public) | [scripts/components.js](scripts/components.js) — `isAdmin` conditionals in `renderNav()` and `renderFooter()` |
| **Admin bypass trigger URL param** | [scripts/components.js](scripts/components.js) — `?admin=madmaps` / `?admin=reset` logic in `DOMContentLoaded` |
| **Nav visual styling** (layout, hover states, spacing) | [styles/components.css](styles/components.css) — `.site-nav`, `.nav-inner`, `.nav-link`, `.nav-toggle` |
| **Footer visual styling** | [styles/components.css](styles/components.css) — `.site-footer`, `.footer-inner`, `.footer-brand`, `.footer-links`, `.footer-legal` |
| **Mobile hamburger toggle behaviour** | [scripts/components.js](scripts/components.js) — `toggle.addEventListener('click', ...)` in `renderNav()` |
| **Active nav link highlighting logic** | [scripts/components.js](scripts/components.js) — `normPath` / `normHref` comparison block in `renderNav()` |

---

## Map — Foundation & Camera

| To change... | Edit these files |
|---|---|
| **Map starting position** (center lat/lng, zoom) | [scripts/map.js](scripts/map.js) — `DEFAULTS.center`, `DEFAULTS.zoom` — OR — Supabase `style_config` table (keys: `map_center_lng`, `map_center_lat`, `map_zoom`) for a no-deploy update |
| **Map starting pitch** (3D tilt angle) | [scripts/map.js](scripts/map.js) — `DEFAULTS.pitch` — OR — Supabase `style_config` key: `map_pitch` |
| **Map starting bearing** (compass rotation) | [scripts/map.js](scripts/map.js) — `DEFAULTS.bearing` — OR — Supabase `style_config` key: `map_bearing` |
| **Camera ease duration** when style_config overrides apply | [scripts/map.js](scripts/map.js) — `cameraUpdate.duration = 1500` in `loadStyleConfig()` |
| **Terrain exaggeration** (3D height multiplier) | [scripts/map.js](scripts/map.js) — `DEFAULTS.terrainExaggeration` — OR — Supabase `style_config` key: `terrain_exaggeration` |
| **Fog settings** (range, color, horizon blend, star intensity) | [scripts/map.js](scripts/map.js) — `map.setFog({...})` call inside `map.on('load', ...)` |
| **Map base style** (water, roads, land, 3D buildings, satellite layer) | Mapbox Studio (external) — then update `MAPBOX_STYLE_URL` env var in Vercel + `.env` |
| **Mapbox GL JS version** | `<script src>` and `<link href>` CDN tags in [pages/map.html](pages/map.html) and [pages/dashboard.html](pages/dashboard.html) |
| **Navigation controls position** (zoom +/- compass) | [scripts/map.js](scripts/map.js) — `map.addControl(new mapboxgl.NavigationControl(), 'top-right')` |
| **Navigation controls styling** | [styles/map.css](styles/map.css) — `.mapboxgl-ctrl-group`, `.mapboxgl-ctrl-group button` |
| **Map error state message** | [scripts/map.js](scripts/map.js) — `showMapError()` HTML string |
| **Map error state styling** | [styles/map.css](styles/map.css) — `.map-error-state` |
| **Map container layout** (full-page vs panel embed) | [styles/map.css](styles/map.css) — `#map-container` (full-page fixed) vs `.map-panel-embed` (relative, panel mode) |
| **Mapbox token or style URL** | Vercel environment variables: `MAPBOX_PUBLIC_TOKEN`, `MAPBOX_STYLE_URL` (+ `.env` locally); never in source code |

---

## Map — Trail Lines

Trail line styling is fully centralised in the `TRAIL_STYLES` object. **Do not edit the layer code** — edit the config object only.

| To change... | Edit these files |
|---|---|
| **Path color** (hiking/running trails — dashed) | [scripts/map.js](scripts/map.js) — `TRAIL_STYLES.path.color` |
| **Path width** at various zooms | [scripts/map.js](scripts/map.js) — `TRAIL_STYLES.path.width` object |
| **Path opacity** at various zooms | [scripts/map.js](scripts/map.js) — `TRAIL_STYLES.path.opacity` object |
| **Path dash pattern** | [scripts/map.js](scripts/map.js) — `TRAIL_STYLES.path.dasharray` |
| **Footway color / width / opacity** | [scripts/map.js](scripts/map.js) — `TRAIL_STYLES.footway.*` |
| **Footway minimum zoom** (zoom level where footways appear) | [scripts/map.js](scripts/map.js) — `TRAIL_STYLES.footway.minzoom` |
| **Steps color / width / opacity / dash** | [scripts/map.js](scripts/map.js) — `TRAIL_STYLES.steps.*` |
| **Steps minimum zoom** | [scripts/map.js](scripts/map.js) — `TRAIL_STYLES.steps.minzoom` |
| **Track color / width / opacity** (jeep roads) | [scripts/map.js](scripts/map.js) — `TRAIL_STYLES.track.*` |
| **Which tileset the trail lines come from** | [scripts/map.js](scripts/map.js) — `source-layer: 'trails-4ee5we'` inside `addDataLayers()` — AND — `TRAILS_TILESET_ID` env var |

---

## Map — Contour Lines

| To change... | Edit these files |
|---|---|
| **Major contour color** (100m intervals) | [scripts/map.js](scripts/map.js) — `CONTOUR_STYLES.majorColor` |
| **Minor contour color** (20m intervals) | [scripts/map.js](scripts/map.js) — `CONTOUR_STYLES.minorColor` |
| **Major contour width** at various zooms | [scripts/map.js](scripts/map.js) — `CONTOUR_STYLES.majorWidth` |
| **Minor contour width** at various zooms | [scripts/map.js](scripts/map.js) — `CONTOUR_STYLES.minorWidth` |
| **Major contour opacity** at various zooms | [scripts/map.js](scripts/map.js) — `CONTOUR_STYLES.majorOpacity` |
| **Minor contour opacity** at various zooms | [scripts/map.js](scripts/map.js) — `CONTOUR_STYLES.minorOpacity` |
| **Zoom at which contours first appear** | [scripts/map.js](scripts/map.js) — `CONTOUR_STYLES.minzoom` |
| **Which tileset the contours come from** | [scripts/map.js](scripts/map.js) — `source-layer: '10m_Contours-57qbiw'` — AND — `CONTOURS_TILESET_ID` env var |

---

## Map — Peak Markers

Marker config is centralised in `MARKER_STYLES.peaks`. For adding bespoke icons, **only the config object changes** — no layer code changes needed.

| To change... | Edit these files |
|---|---|
| **Generic T1 peak icon** (small, zoom < 13) | Replace [public/icons/peaks/t1-peak-generic.svg](public/icons/peaks/t1-peak-generic.svg) — and if renaming, update [scripts/map.js](scripts/map.js) `MARKER_STYLES.peaks.icons.t1.file` |
| **Generic T2 peak icon** (medium, zoom ≥ 13) | Replace [public/icons/peaks/t2-peak-generic.svg](public/icons/peaks/t2-peak-generic.svg) — and if renaming, update `MARKER_STYLES.peaks.icons.t2.file` |
| **Generic icon rendered sizes** (px canvas size) | [scripts/map.js](scripts/map.js) — `MARKER_STYLES.peaks.icons.t1.size` and `.t2.size` |
| **Zoom where T1 → T2 icon swaps** | [scripts/map.js](scripts/map.js) — `MARKER_STYLES.peaks.iconSwitch` (default: 13) |
| **Add a bespoke T3 peak icon** (hover/detail state) | [scripts/map.js](scripts/map.js) — add entry to `MARKER_STYLES.peaks.bespoke` with the peak name as key; + add SVG to [public/icons/peaks/](public/icons/peaks/) |
| **Change an existing bespoke peak icon file** | Replace SVG in [public/icons/peaks/](public/icons/peaks/) — and if renaming, update `MARKER_STYLES.peaks.bespoke["Peak Name"].t3.file` |
| **Bespoke T3 icon rendered size** | [scripts/map.js](scripts/map.js) — `MARKER_STYLES.peaks.bespoke["Name"].t3.size` |
| **Mobile tap: duration T3 icon stays visible** | [scripts/map.js](scripts/map.js) — `setTimeout(..., 3000)` inside `setupHoverInteractions()` |
| **Zoom at which peaks first appear** | [scripts/map.js](scripts/map.js) — `addPeakLayers()` — `minzoom: 8` on the base layer |
| **Zoom at which peak labels appear** | [scripts/map.js](scripts/map.js) — `addPeakLayers()` — `'text-field': ['step', ['zoom'], '', 13, ...]` |
| **Peak marker visual scale** (icon-size interpolation) | [scripts/map.js](scripts/map.js) — `addPeakLayers()` — `icon-size` interpolation array |
| **Peak label text color** | [scripts/map.js](scripts/map.js) — `addPeakLayers()` — `paint['text-color']` |
| **Peak label halo color** | [scripts/map.js](scripts/map.js) — `addPeakLayers()` — `paint['text-halo-color']` |
| **Peak label font** | [scripts/map.js](scripts/map.js) — `addPeakLayers()` — `layout['text-font']` array |
| **Allow peaks to overlap at low zoom** | [scripts/map.js](scripts/map.js) — `addPeakLayers()` — `icon-allow-overlap` step expression |
| **Peak data** (names, coordinates, elevations) | [public/data/peaks.geojson](public/data/peaks.geojson) |

---

## Map — Cave Markers

Same architecture as peaks. `MARKER_STYLES.caves` is the config object.

| To change... | Edit these files |
|---|---|
| **Generic T1/T2 cave icons** | Replace SVGs in [public/icons/caves/](public/icons/caves/) — update `MARKER_STYLES.caves.icons.t1.file` / `.t2.file` in [scripts/map.js](scripts/map.js) if renaming |
| **Zoom where T1 → T2 cave icon swaps** | [scripts/map.js](scripts/map.js) — `MARKER_STYLES.caves.iconSwitch` |
| **Add a bespoke T3 cave icon** | [scripts/map.js](scripts/map.js) — add entry to `MARKER_STYLES.caves.bespoke`; + add SVG to [public/icons/caves/](public/icons/caves/) |
| **Cave marker size / label / font / zoom thresholds** | [scripts/map.js](scripts/map.js) — `addCaveLayers()` — same pattern as `addPeakLayers()` |
| **Filter: only show named caves** | [scripts/map.js](scripts/map.js) — `MARKER_STYLES.caves.filter: ['has', 'name']` |
| **Cave data** (names, coordinates) | [public/data/caves.geojson](public/data/caves.geojson) |

---

## Map — Graded Routes

| To change... | Edit these files |
|---|---|
| **Add a new graded route** | [scripts/map.js](scripts/map.js) — add path to `RMM_ROUTES` array; + add GeoJSON file to [public/data/routes/](public/data/routes/) |
| **Remove a route** | [scripts/map.js](scripts/map.js) — remove path from `RMM_ROUTES`; delete GeoJSON file from [public/data/routes/](public/data/routes/) |
| **Route line color (per grade)** | [scripts/map.js](scripts/map.js) — `loadRMMRoutes()` — `'line-color'` is a `match` expression on `properties.grade` (A–F) on the `rmm-routes` layer; edit the colour values inside the match arms to retune the grade palette |
| **Route line width** at various zooms | [scripts/map.js](scripts/map.js) — `loadRMMRoutes()` — `'line-width'` interpolation on the `rmm-routes` layer |
| **Route line default opacity** | [scripts/map.js](scripts/map.js) — `loadRMMRoutes()` — `'line-opacity': 0.5` on the `rmm-routes` layer |
| **Route highlight on hover** (color, width, opacity) | [scripts/map.js](scripts/map.js) — `loadRMMRoutes()` — `rmm-routes-highlight` layer paint properties |
| **Route label text** (field, font, color, halo, size) | [scripts/map.js](scripts/map.js) — `loadRMMRoutes()` — `rmm-route-labels` layer layout and paint |
| **Route label minimum zoom** | [scripts/map.js](scripts/map.js) — `loadRMMRoutes()` — `minzoom: 12` on `rmm-route-labels` |
| **Route start dot** (radius, color, opacity, stroke) | [scripts/map.js](scripts/map.js) — `loadRMMRoutes()` — `rmm-route-starts` layer paint properties |
| **Route popup content** (grade, name, distance, elevation stats, CTA text) | [scripts/map.js](scripts/map.js) — `loadRMMRoutes()` — `html` string inside `mouseenter` on `rmm-route-starts` |
| **Route popup properties** (which GeoJSON fields are displayed) | The relevant GeoJSON file in [public/data/routes/](public/data/routes/) — add/rename properties; then update popup HTML in [scripts/map.js](scripts/map.js) |
| **Route popup visual styling** | [styles/map.css](styles/map.css) — `.rmm-route-popup`, `.rmm-route-card`, `.rmm-route-card-grade`, `.rmm-route-card-name`, `.rmm-route-card-stats`, `.rmm-route-card-action` |
| **Pulse dot appearance** (size, color, glow) | [styles/map.css](styles/map.css) — `.rmm-pulse-dot` |
| **Pulse dot animation speed** | [scripts/map.js](scripts/map.js) — `startRoutePulse()` — `PX_PER_MS = 0.08` (~80 px/s, zoom-independent). Per-step `delay = Math.max(16, Math.round(dist / PX_PER_MS))` |
| **When pulse starts/stops** | [scripts/map.js](scripts/map.js) — `mouseenter`/`mouseleave` handlers on `rmm-routes` and `rmm-route-starts` |
| **Route geographic data** (coordinates, grade, distance, elevation) | The relevant GeoJSON file in [public/data/routes/](public/data/routes/) |

---

## Map — Trail Start Clusters

When two or more graded routes share a start coordinate, the GL `rmm-route-starts` layer collapses to a single primary DOM marker that fans out to children on hover/tap. Geometry is in pixel space so spacing is zoom-stable.

| To change... | Edit these files |
|---|---|
| **Cluster fan-out radius** (px from primary centre) | [scripts/map.js](scripts/map.js) — `loadRMMRoutes()` → `expandCluster()` — `var radius = 26` |
| **Cluster angular gap between children** | [scripts/map.js](scripts/map.js) — `expandCluster()` — `FIXED_GAP = 40 * Math.PI / 180` |
| **Cluster fan start angle** (currently 9 o'clock, going clockwise) | [scripts/map.js](scripts/map.js) — `expandCluster()` — `startAngle = Math.PI` (screen coords: y-down ⇒ angle increases visually clockwise) |
| **Full-circle fallback threshold** (when too many children to fit at fixed gap) | [scripts/map.js](scripts/map.js) — `expandCluster()` — `FULL_CIRCLE_THRESHOLD = 9` |
| **Parent shrink scale on expand** | [styles/map.css](styles/map.css) — `.rmm-cluster-primary-wrap.is-expanded .rmm-cluster-primary` — `scale(calc(var(--rmm-cluster-scale, 1) * 0.7))` |
| **Cluster zoom-scale parity** (matches GL singleton sizing across zooms) | [scripts/map.js](scripts/map.js) — `computeClusterPrimaryScale(zoom)` and `syncClusterScale()` inside `loadRMMRoutes()` |
| **Cluster primary appearance** (size, colour, border) | [styles/map.css](styles/map.css) — `.rmm-cluster-primary-wrap` (hit area), `.rmm-cluster-primary` (visible circle) |
| **Cluster secondary appearance** | [styles/map.css](styles/map.css) — `.rmm-cluster-secondary-wrap`, `.rmm-cluster-secondary` |
| **Cluster fan-in animation** (timing, overshoot, stagger) | [styles/map.css](styles/map.css) — `@keyframes rmm-cluster-secondary-in` (curve, duration); [scripts/map.js](scripts/map.js) — `inner.style.animationDelay = (i * 30) + 'ms'` (per-index stagger) |
| **Parent shrink animation timing** | [styles/map.css](styles/map.css) — `.rmm-cluster-primary` `transition: transform 240ms cubic-bezier(0.4, 0, 0.2, 1)` |
| **Reduced-motion behaviour** | [styles/map.css](styles/map.css) — `@media (prefers-reduced-motion: reduce)` block in the cluster section |
| **Cluster collapse debounce** (gap traversal grace period) | [scripts/map.js](scripts/map.js) — `scheduleCollapse()` — `setTimeout(collapseCluster, 350)` |
| **SVG hover bridge padding** (extra hit area between primary and children) | [scripts/map.js](scripts/map.js) — `createBridge()` — `var pad = 12` |
| **Cluster popup positioning** (always below cluster, edge fallback) | [scripts/map.js](scripts/map.js) — secondary `mouseenter` inside `expandCluster()` — `(pxBelow < APPROX_POPUP_HEIGHT) ? 'bottom' : 'top'` |
| **Cluster popup edge-fallback threshold** (px from bottom of viewport) | [scripts/map.js](scripts/map.js) — `expandCluster()` — `var APPROX_POPUP_HEIGHT = 160` |
| **Mobile/touch dismissal** (tap outside or pan/zoom collapses) | [scripts/map.js](scripts/map.js) — `map.on('click', ...)` and `map.on('movestart', ...)` near the bottom of `loadRMMRoutes()` |
| **Hide cluster markers** (e.g. when filter toggle is off) | [styles/map.css](styles/map.css) — `.rmm-clusters-hidden .rmm-cluster-primary-wrap, .rmm-cluster-secondary-wrap` |

---

## Map — Filter Sidebar

The filter sidebar is built dynamically by `buildFilterSidebar()` in `map.js`. All toggleable layer groups are defined in the `FILTER_GROUPS` config object — no HTML file changes needed.

| To change... | Edit these files |
|---|---|
| **Add/remove a toggleable layer group** | [scripts/map.js](scripts/map.js) — `FILTER_GROUPS` object |
| **Add a layer to an existing group** | [scripts/map.js](scripts/map.js) — add GL layer ID(s) to the relevant `FILTER_GROUPS` item's `layers` array |
| **Enable a placeholder toggle** (Events, POIs, Zones) | [scripts/map.js](scripts/map.js) — remove `placeholder: true` from the item in `FILTER_GROUPS.future`, add real layer IDs to its `layers` array |
| **Section labels** (Markers, Routes, Trails, etc.) | [scripts/map.js](scripts/map.js) — `FILTER_GROUPS[group].label` |
| **Toggle button position** (top-left) | [styles/map.css](styles/map.css) — `.rmm-filter-toggle` |
| **Panel width** | [styles/map.css](styles/map.css) — `.rmm-filter-panel` `width` (240px desktop, 220px mobile) |
| **Panel styling** (background, borders, section labels) | [styles/map.css](styles/map.css) — `.rmm-filter-panel`, `.rmm-filter-header`, `.rmm-filter-section`, `.rmm-filter-section-label` |
| **Toggle switch styling** (track, thumb, active color) | [styles/map.css](styles/map.css) — `.rmm-toggle`, `.rmm-toggle-track` |
| **Row label styling** | [styles/map.css](styles/map.css) — `.rmm-filter-row-label` |
| **DOM marker hiding** (cluster markers when routes toggled off) | [styles/map.css](styles/map.css) — `.rmm-clusters-hidden` rule |
| **Dismissal behaviour** (Escape, click-outside, X button) | [scripts/map.js](scripts/map.js) — event listeners at bottom of `buildFilterSidebar()` |

---

## Map — Account Signup Overlay (formerly Email Signup Overlay)

The overlay is fully self-contained inside `map.js`. It only appears on the `/map` page (when `#map-container` exists).

| To change... | Edit these files |
|---|---|
| **Overlay headline / eyebrow / body copy** | [scripts/map.js](scripts/map.js) — `initEmailOverlay()` — HTML string |
| **Go live** (enable signup CTA) | [scripts/map.js](scripts/map.js) — set `RMM_OVERLAY_LIVE = true` (near top of overlay section) |
| **CTA button text** (live mode) | [scripts/map.js](scripts/map.js) — `initEmailOverlay()` — `<a>` in the `RMM_OVERLAY_LIVE` branch |
| **CTA button text** (coming soon mode) | [scripts/map.js](scripts/map.js) — `initEmailOverlay()` — disabled `<button>` in the `!RMM_OVERLAY_LIVE` branch |
| **Dismiss button text** | [scripts/map.js](scripts/map.js) — `initEmailOverlay()` — `id="overlay-dismiss"` button text |
| **Suppress overlay** (subscribed or logged in) | [scripts/map.js](scripts/map.js) — `handleOverlaySubmit()` — `card.innerHTML = '<p ...>You\'re in...'` |
| **Auto-subscribe on platform signup** | [api/auth/account.js](api/auth/account.js) — `handleOverlaySubmit()` — `setTimeout(dismissOverlay, 2000)` |
| **Overlay on mobile** (bottom-sheet layout) | [styles/map.css](styles/map.css) — `handleOverlaySubmit()` — `errorEl.textContent` assignments |
| **Overlay layout and visual styling** | [styles/map.css](styles/map.css) — `.rmm-overlay-backdrop`, `.rmm-overlay-card`, `.rmm-overlay-eyebrow`, `.rmm-overlay-headline`, `.rmm-overlay-body`, `.rmm-overlay-field`, `.rmm-overlay-submit`, `.rmm-overlay-dismiss`, `.rmm-overlay-error`, `.rmm-overlay-success` |
| **Overlay on mobile** (bottom-sheet layout) | [styles/map.css](styles/map.css) — `.rmm-overlay-card` inside `@media` query |
| **Suppress overlay** (once subscribed) | [scripts/map.js](scripts/map.js) — `localStorage.getItem('rmm_subscribed') === 'true'` check in `initEmailOverlay()` |
| **Overlay Escape key dismiss** | [scripts/map.js](scripts/map.js) — `document.addEventListener('keydown', ...)` in `initEmailOverlay()` |
| **Which pages show the overlay** | [scripts/map.js](scripts/map.js) — `DOMContentLoaded` block at the bottom: `initEmailOverlay()` is only called when `#map-container` exists |

---

## Authentication System

The auth system uses a consolidated endpoint pattern to stay under Vercel Hobby plan's 12-function limit. Three actions route through `account.js` via `?action=` query parameter. The client module `auth.js` handles session state across all pages.

| To change... | Edit these files |
|---|---|
| **Signup logic** (validation, password hashing, race number generation) | [api/auth/account.js](api/auth/account.js) — `handleSignup()` function |
| **Signin logic** (credential verification) | [api/auth/account.js](api/auth/account.js) — `handleSignin()` function |
| **Admin grant logic** | [api/auth/account.js](api/auth/account.js) — `handleAdminGrant()` function |
| **Session cookie settings** (name, max-age, httpOnly, Secure, remember-me) | [api/auth/account.js](api/auth/account.js) — `setSessionCookie()` helper. Cookie duration: 30-day if remember-me checked or signup; session cookie otherwise |
| **Platform version enforcement** (force re-login on platform update) | [api/auth/session.js](api/auth/session.js) — checks `session_version` vs `RMM_PLATFORM_VERSION` env var; [api/auth/account.js](api/auth/account.js) — stamps `session_version` at login/signup |
| **Nav auth state on all pages** (Sign In ↔ Profile toggle) | [scripts/components.js](scripts/components.js) — `updateNavAuth()` + `applyNavAuthState()`. Does lightweight `/api/auth/session` fetch when `auth.js` isn't loaded |
| **Race number format or range** | [api/auth/account.js](api/auth/account.js) — `generateRaceNumber()` helper |
| **Auto-admin email address** | [api/auth/account.js](api/auth/account.js) — `handleSignup()` — hardcoded founder email check |
| **Session lookup** (which tables, which fields) | [api/auth/session.js](api/auth/session.js) — main handler: tries `users` table first, falls back to `athletes` |
| **Strava data enrichment on session** | [api/auth/session.js](api/auth/session.js) — `getStravaAthleteData()` function |
| **Strava token auto-refresh** | [api/auth/session.js](api/auth/session.js) — `refreshStravaToken()` + `updateStravaTokens()` |
| **Client-side auth state** (session fetch, login/logout, page gating) | [scripts/auth.js](scripts/auth.js) — `RMMAuth` module |
| **Three-state page gating** (logged out / no Strava / Strava connected) | [scripts/auth.js](scripts/auth.js) — `RMMAuth.onReady()` callback pattern; gating HTML in each page |
| **Signup page** (form, validation, UX) | [pages/signup.html](pages/signup.html) |
| **Signin page** (form, validation, UX) | [pages/signin.html](pages/signin.html) |
| **Profile page** (race card, account details, Strava panel, admin controls) | [pages/profile.html](pages/profile.html) |
| **Auth-related CSS** (forms, cards, badges, profile panels) | [styles/pages.css](styles/pages.css) — `.auth-*` and `.profile-*` classes |
| **Nav auth links** (Profile, Sign In/Out) | [scripts/components.js](scripts/components.js) — `renderNav()` auth-aware section |
| **Strava OAuth flow** (login redirect, callback, token storage) | [api/auth/strava-login.js](api/auth/strava-login.js) + [api/auth/strava-callback.js](api/auth/strava-callback.js) |
| **Logout** (cookie clear, session invalidation, redirect) | [api/auth/logout.js](api/auth/logout.js) — clears `rmm_session` cookie AND invalidates `session_token` (+ `session_version`) in both `users` and `athletes` tables (dual-table logout, fixed 2026-05-12) |

---

## API Endpoints

| To change... | Edit these files |
|---|---|
| **Email submission validation logic** | [api/subscribe.js](api/subscribe.js) — validation section |
| **Platform signup auto-subscribe source tag** | [api/auth/account.js](api/auth/account.js) — `handleSignup()` — `source: 'platform-signup'` in subscriber insert |
| **Which Supabase table stores subscribers** | [api/subscribe.js](api/subscribe.js) — `/rest/v1/subscribers` fetch URL |
| **Subscriber fields written to Supabase** | [api/subscribe.js](api/subscribe.js) — the insert body object |
| **Mapbox token delivery endpoint** | [api/auth/session.js](api/auth/session.js) — `handleMapConfig()` function (consolidated from old api/config.js; routed via `?type=mapconfig`) |
| **Allowed CORS origins** for map config | [api/auth/session.js](api/auth/session.js) — `handleMapConfig()` — `allowedOrigins` array |
| **Additional config values delivered to client** | [api/auth/session.js](api/auth/session.js) — `handleMapConfig()` response JSON object |
| **Supabase URL and keys** (production) | Vercel dashboard — `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` |
| **Supabase URL and keys** (local dev) | [.env](.env) — not committed; see [.env.example](.env.example) for key names |

---

## Adding New Pages

This is a multi-file operation. Three steps, always:

1. **Create the HTML file** — [pages/newpage.html](pages/) — copy the shell from any existing page (`about.html` is the cleanest template); update `<title>`, `<meta>`, and page content
2. **Add the URL rewrite** — [vercel.json](vercel.json) — add `{ "source": "/newpage", "destination": "/pages/newpage.html" }` to the `rewrites` array
3. **Add nav links** (if the page should be in the nav) — [scripts/components.js](scripts/components.js) — `renderNav()` and `renderFooter()`

| To change... | Edit these files |
|---|---|
| **Add a new page** | New `pages/*.html` + [vercel.json](vercel.json) rewrites |
| **Change a page's URL** | [vercel.json](vercel.json) — `source` field in the relevant rewrite rule |
| **Add security headers** | [vercel.json](vercel.json) — `headers` array |
| **Change routing behaviour** | [vercel.json](vercel.json) |

---

## Page Content — Static Pages

| To change... | Edit these files |
|---|---|
| **About page** — any section (hero, systems, grading scale, RPS weights, readiness checks, founder bio, etc.) | [pages/about.html](pages/about.html) |
| **Dashboard layout** — panels, rows, placeholder content | [pages/dashboard.html](pages/dashboard.html) |
| **Intelligence hub** — tool descriptions, feature cards, CTAs | [pages/intelligence.html](pages/intelligence.html) |
| **RPS / Fitness page** — component weights, level bands, descriptions | [pages/intelligence-fitness.html](pages/intelligence-fitness.html) |
| **Route grading page** (explainer) — grade descriptions, validated routes table | [pages/intelligence-routes.html](pages/intelligence-routes.html) |
| **Route grading tool** — GPX upload, save, admin toggles, duplicate detection, history | [pages/intelligence-route-grading.html](pages/intelligence-route-grading.html) |
| **RPS deep-dive page** — full RPS breakdown with live score display | [pages/intelligence-rps.html](pages/intelligence-rps.html) |
| **Race readiness page** (explainer) — 5 checks, 3 verdicts | [pages/intelligence-readiness.html](pages/intelligence-readiness.html) |
| **Race readiness tool** — route selector, verdict hero, five check cards, PI detail, summary | [pages/intelligence-race-readiness.html](pages/intelligence-race-readiness.html) |
| **Leaderboards page** — leaderboard types, placeholder table | [pages/leaderboards.html](pages/leaderboards.html) |
| **Event page** — event name, grade, stats, tier pricing, map/profile placeholders | [pages/event.html](pages/event.html) |
| **Shop page** — product grid, products, prices | [pages/shop.html](pages/shop.html) |
| **Product page** — product name, specs, images, pricing, related products | [pages/product.html](pages/product.html) |
| **Privacy policy** | [pages/privacy.html](pages/privacy.html) |
| **Terms of service** | [pages/terms.html](pages/terms.html) |
| **Cookie policy** | [pages/cookies.html](pages/cookies.html) |
| **Acceptable use policy** | [pages/acceptable-use.html](pages/acceptable-use.html) |
| **Legal index page** | [pages/legal.html](pages/legal.html) |

---

## Page Styling — Sections & Components

| To change... | Edit these files |
|---|---|
| **About page section styles** (`.about-*`) | [styles/pages.css](styles/pages.css) |
| **Dashboard panel/grid styles** (`.dash-*`) | [styles/pages.css](styles/pages.css) |
| **Intelligence page styles** (`.intel-*`) | [styles/pages.css](styles/pages.css) |
| **Fitness page component grid / level bands** (`.component-*`, `.levels-strip`) | [styles/pages.css](styles/pages.css) |
| **Route grading page grade cards** (`.grade-grid`, `.grade-a` … `.grade-f`, `.routes-table`) | [styles/pages.css](styles/pages.css) |
| **Route grading tool styles** (`.rg-upload-area`, `.rg-grade-hero`, `.rg-stats-grid`, `.rg-history-table`, `.rg-admin-section`, `.rg-toggle`, `.rg-duplicate-alert`) | [styles/pages.css](styles/pages.css) |
| **RPS deep-dive page styles** (`rps-page-*`) | [styles/pages.css](styles/pages.css) |
| **Race Readiness tool styles** (`.rr-*` — selector, verdict hero, check cards, route card, PI table, summary) | [styles/pages.css](styles/pages.css) |
| **Nav dropdown styles** (`.nav-dropdown`, `.nav-dropdown-menu`, `.nav-dropdown-item`) | [styles/components.css](styles/components.css) |
| **Remember-me checkbox styles** (`.auth-remember-*`) | [styles/pages.css](styles/pages.css) |
| **Readiness page checks / verdict cards** (`.checks-grid`, `.verdict-*`) | [styles/pages.css](styles/pages.css) |
| **Leaderboard page styles** (`.leaderboard-*`) | [styles/pages.css](styles/pages.css) |
| **Event page styles** (`.event-layout`, `.event-grade-badge`, `.event-tiers`) | [styles/pages.css](styles/pages.css) |
| **Shop / product page styles** (`.shop-grid`, `.product-card`, `.product-layout`) | [styles/pages.css](styles/pages.css) |
| **Shared page header** (`.page-header`, `.page-header-title`, `.page-header-subtitle`) | [styles/components.css](styles/components.css) |
| **Shared section wrapper** (`.section`, `.section-label`, `.section-heading`, `.section-body`) | [styles/components.css](styles/components.css) |
| **Coming soon badge** (`.coming-soon-badge`) | [styles/components.css](styles/components.css) |
| **Page shell / content wrapper** (`.page-shell`, `.page-content`) | [styles/components.css](styles/components.css) |

---

## Static Geographic Data

| To change... | Edit these files |
|---|---|
| **Peak locations, names, or elevations** | [public/data/peaks.geojson](public/data/peaks.geojson) |
| **Cave locations or names** | [public/data/caves.geojson](public/data/caves.geojson) |
| **Route data** (trails) | Routes are now managed via the Trail Library admin tool and served from Supabase via API (`/api/python/trails?action=list`). Static GeoJSON route files in `/public/data/routes/` are legacy and no longer used. |
| **POI data** | POIs are managed via the POI Manager admin tool and served from Supabase via API (`/api/python/pois`). No static GeoJSON for POIs. |

---

## Icon Files

| To change... | Edit these files |
|---|---|
| **T1 peak icon** (small, generic) | [public/icons/peaks/t1-peak-generic.svg](public/icons/peaks/t1-peak-generic.svg) |
| **T2 peak icon** (medium, generic) | [public/icons/peaks/t2-peak-generic.svg](public/icons/peaks/t2-peak-generic.svg) |
| **T3 Maclear's Beacon hover icon** | [public/icons/peaks/t3-peak-maclears-beacon.svg](public/icons/peaks/t3-peak-maclears-beacon.svg) — apostrophe-free filename (renamed 2026-04-30, commit `1a98108`) |
| **T4 Maclear's Beacon detail icon** | [public/icons/peaks/t4-peak-maclears-beacon.svg](public/icons/peaks/t4-peak-maclears-beacon.svg) (not yet wired to a layer) — apostrophe-free filename |
| **T1 cave icon** (small, generic) | [public/icons/caves/t1-cave-generic.svg](public/icons/caves/t1-cave-generic.svg) |
| **T2 cave icon** (medium, generic) | [public/icons/caves/t2-cave-generic.svg](public/icons/caves/t2-cave-generic.svg) |
| **T3 Boomslang Cave hover icon** | [public/icons/caves/t3-cave-boomslang-cave.svg](public/icons/caves/t3-cave-boomslang-cave.svg) |
| **T4 Boomslang Cave detail icon** | [public/icons/caves/t4-cave-boomslang-cave.svg](public/icons/caves/t4-cave-boomslang-cave.svg) (not yet wired to a layer) |
| **Wire a T4 icon to a new detail layer** | [scripts/map.js](scripts/map.js) — create a new layer function; add the icon to `MARKER_STYLES.[category].icons` or `.bespoke` |
| **Add a new icon category** (events, POIs, zones) | Add SVGs to [public/icons/[category-plural]/](public/icons/); add config to [scripts/map.js](scripts/map.js) `MARKER_STYLES`; add `addSource()` + new layer function in `addDataLayers()` |

---

## Animations

| To change... | Edit these files |
|---|---|
| **Route pulse dot** (the red animated dot on route hover) — appearance | [styles/map.css](styles/map.css) — `.rmm-pulse-dot` |
| **Route pulse dot** — speed | [scripts/map.js](scripts/map.js) — `startRoutePulse()` — `speed` calculation |
| **Route pulse dot** — when it starts/stops | [scripts/map.js](scripts/map.js) — `mouseenter`/`mouseleave` handlers on `rmm-routes` and `rmm-route-starts` |
| **Intro animation** (fly-in camera, Stage 4) | **Not yet implemented.** Will live in [scripts/map.js](scripts/map.js) as a `map.flyTo()` or `map.easeTo()` sequence called after `map.on('load')` |
| **Stage 5 animation system** | **Not yet implemented.** Will live in [scripts/map.js](scripts/map.js) and/or [public/animations/](public/animations/) (sprite sheets) |

---

## Supabase / Dynamic Config

| To change... | Edit these files |
|---|---|
| **Map camera** (without a code deploy) | Supabase `style_config` table — keys: `map_center_lng`, `map_center_lat`, `map_zoom`, `map_pitch`, `map_bearing` |
| **Terrain exaggeration** (without a code deploy) | Supabase `style_config` table — key: `terrain_exaggeration` |
| **Which style_config keys map.js reads** | [scripts/map.js](scripts/map.js) — `loadStyleConfig()` function |
| **Supabase project URL** | [scripts/map.js](scripts/map.js) — `SUPABASE_URL` constant (client-side read); `SUPABASE_URL` env var (server-side write) |
| **Supabase anon key** | [scripts/map.js](scripts/map.js) — `SUPABASE_ANON_KEY` constant — safe to be in client code (read-only) |
| **Supabase service role key** | `.env` locally; Vercel env var `SUPABASE_SERVICE_ROLE_KEY` in production — never in source code |

---

## Trail Library (Admin) — Added 2026-05-19

| To change... | Edit these files |
|---|---|
| **Trail Library page** (layout, sections, modals) | [pages/intelligence-trail-library.html](pages/intelligence-trail-library.html) |
| **Trail Library JS** (upload, grading, table, segment editor, rename, map preview) | [scripts/trail-library.js](scripts/trail-library.js) |
| **Trail Library styling** (`.tl-*` prefix: upload area, table, filters, buttons) | [styles/pages.css](styles/pages.css) |
| **Segment editor modal styling** (`.seg-*` prefix: modal, scrub bar, cards, snip tool) | [styles/pages.css](styles/pages.css) |
| **Trail CRUD backend** (create from GPX, update, archive, list, segment CRUD, snip) | [api/python/trails.py](api/python/trails.py) |
| **Descent grading engine** (DDS calculation, switchback detection, composite grade builder) | [api/python/_descent_grader.py](api/python/_descent_grader.py) |
| **Descent detection in GPS processor** (`_detect_descents()` method) | [api/python/_gps_processor.py](api/python/_gps_processor.py) |
| **DDS env vars** (weights, grade thresholds, normalisation ceilings) | Vercel env vars — see `vercel-dds-env-vars.txt` for names/values. [api/python/_config.py](api/python/_config.py) reads them. |
| **Trail Library admin nav link** | [scripts/components.js](scripts/components.js) — `addAdminNavLinks()` function |
| **Trail Library URL route** | [vercel.json](vercel.json) — `/intelligence/trail-library` rewrite |
| **Event type options** (trail, time trial, hill climb, hill bomb) | Supabase `event_types` table (no code change needed to add new types) |
| **Trail status flow** (draft → live → archived) | [api/python/trails.py](api/python/trails.py) — `_update_trail()` function |
| **Admin auth in trails.py** (session cookie → users table lookup) | [api/python/trails.py](api/python/trails.py) — `_check_admin()` function |
| **Map preview in trail library** (Mapbox modal) | [scripts/trail-library.js](scripts/trail-library.js) — `openMapPreview()` / `closeMapPreview()` |
| **Segment editor UI** (per-km cards, notes, tags, terrain toggle) | [scripts/trail-library.js](scripts/trail-library.js) — `openSegmentEditor()`, `buildSegmentCard()`, `handleSegmentSave()` |
| **Snip tool** (extract km range as new draft trail) | [scripts/trail-library.js](scripts/trail-library.js) — `handleSnip()`; backend: [api/python/trails.py](api/python/trails.py) — `_snip_segment()` |

---

## POI Manager (Admin) — Added 2026-05-20

| To change... | Edit these files |
|---|---|
| **POI Manager page** (layout, form, modals) | [pages/intelligence-poi-manager.html](pages/intelligence-poi-manager.html) |
| **POI Manager JS** (CRUD, DDM converter, map preview, icon preview, edit modal) | [scripts/poi-manager.js](scripts/poi-manager.js) |
| **POI Manager styling** (`.poi-` prefix: form, table, modals) | [styles/pages.css](styles/pages.css) |
| **POI CRUD backend** (create, update, delete, list) | [api/python/trails.py](api/python/trails.py) — `_create_poi()`, `_update_poi()`, `_delete_poi()`, `_get_all_pois()`, `_get_pois()` |
| **POI categories** (14 built-in types) | Hardcoded in `poi-manager.js` `POI_CATEGORIES` object and `trail-detail.js` `POI_CATEGORIES` object |
| **POI icons** (T1 24px, T2 32px per category) | [public/icons/pois/](public/icons/pois/) — 28 SVG files following `t1-poi-[key].svg` / `t2-poi-[key].svg` naming |
| **DDM coordinate converter** | [scripts/poi-manager.js](scripts/poi-manager.js) — `convertDdmCoords()` and `parseDdm()` functions |
| **POI map preview modal** | [scripts/poi-manager.js](scripts/poi-manager.js) — `openPoiMapPreview()` / `closePoiMapPreview()` |
| **POI Manager admin nav link** | [scripts/components.js](scripts/components.js) — `addAdminNavLinks()` function (Intelligence dropdown) |

---

## Trail Detail Page (Public) — Added 2026-05-21

| To change... | Edit these files |
|---|---|
| **Trail detail page** (layout, sections) | [pages/trail.html](pages/trail.html) |
| **Trail detail JS** (rendering, mini-map, elevation profile) | [scripts/trail-detail.js](scripts/trail-detail.js) |
| **Trail detail styling** (`.td-` prefix: hero, grades, stats, profile, segments, POIs) | [styles/pages.css](styles/pages.css) |
| **Grade colours** (A–F colour mapping) | [scripts/trail-detail.js](scripts/trail-detail.js) — `GRADE_COLORS` object |
| **Event type display labels** | [scripts/trail-detail.js](scripts/trail-detail.js) — `EVENT_LABELS` object |
| **POI category display labels** | [scripts/trail-detail.js](scripts/trail-detail.js) — `POI_CATEGORIES` object |
| **Trail detail API** (public GET by slug) | [api/python/trails.py](api/python/trails.py) — `_get_trail_detail()` |
| **Trail detail URL routing** | [vercel.json](vercel.json) — `/trail/:slug*` rewrite |
| **Composite grade card rendering** (climb + descent) | [scripts/trail-detail.js](scripts/trail-detail.js) — `renderCompositeGrades()` |
| **Mini-map rendering** (Mapbox with trail line) | [scripts/trail-detail.js](scripts/trail-detail.js) — `renderMiniMap()` |
| **Elevation profile SVG** | [scripts/trail-detail.js](scripts/trail-detail.js) — `renderElevationProfile()` |

---

## Trail Browse Page (Public) — Added 2026-05-21

| To change... | Edit these files |
|---|---|
| **Trail browse page** (layout, filters, grid) | [pages/trails.html](pages/trails.html) |
| **Trail browse JS** (fetch, filter, sort, card rendering) | [scripts/trail-browse.js](scripts/trail-browse.js) |
| **Trail browse styling** (`.tb-` prefix: filters, grid, cards) | [styles/pages.css](styles/pages.css) |
| **Grade colours** | [scripts/trail-browse.js](scripts/trail-browse.js) — `GRADE_COLORS` object |
| **Event type labels** | [scripts/trail-browse.js](scripts/trail-browse.js) — `EVENT_LABELS` object |
| **Grade sort order** | [scripts/trail-browse.js](scripts/trail-browse.js) — `GRADE_ORDER` object |
| **Browse API** (lightweight public list) | [api/python/trails.py](api/python/trails.py) — `_browse_trails()` |
| **Browse URL routing** | [vercel.json](vercel.json) — `/trails` rewrite |

---

## 404 Page — Added 2026-05-21

| To change... | Edit these files |
|---|---|
| **404 page** (content, messaging) | [pages/404.html](pages/404.html) — also copied to project root `404.html` for Vercel auto-serving |
| **404 styling** (`.error-page`, `.error-code`, `.error-message`) | [styles/pages.css](styles/pages.css) |

---

## Map — POI Markers (Added 2026-05-20)

| To change... | Edit these files |
|---|---|
| **POI data source** (API endpoint) | [scripts/map.js](scripts/map.js) — `addPOILayers()` fetches from `/api/python/pois` |
| **POI icon mapping** (category → icon) | [scripts/map.js](scripts/map.js) — `addPOILayers()` — GL `match` expression on `category` property |
| **POI T1/T2 icon files** | [public/icons/pois/](public/icons/pois/) — `t1-poi-[key].svg` / `t2-poi-[key].svg` |
| **POI icon sizes** (T1=24px, T2=32px) | [scripts/map.js](scripts/map.js) — `addPOILayers()` icon loading |
| **POI zoom threshold** (T1→T2 swap) | [scripts/map.js](scripts/map.js) — `addPOILayers()` — `step` expression at zoom 13 |
| **POI hover popup** (name only) | [scripts/map.js](scripts/map.js) — `addPOILayers()` mouseenter handler |
| **POI detail popup** (click, shows category + description) | [scripts/map.js](scripts/map.js) — `addPOILayers()` click handler with `mapboxgl.Popup` using `className: 'rmm-poi-detail-popup'` |
| **POI popup styling** | [styles/map.css](styles/map.css) — `.rmm-poi-popup`, `.rmm-poi-detail-popup` |
| **POI filter sidebar toggle** | [scripts/map.js](scripts/map.js) — `FILTER_GROUPS` config — POIs entry with `layers` array |

---

## Map — Route Popup Updates (Updated 2026-05-21)

| To change... | Edit these files |
|---|---|
| **Route popup event type labels** | [scripts/map.js](scripts/map.js) — `_eventLabels` object and `_eventLabel()` helper |
| **Route popup trail detail link** | [scripts/map.js](scripts/map.js) — popup HTML in both mouseenter handlers (cluster click ~line 1232 and route-starts ~line 1358) |
| **Route popup linger delay** (350ms for clickability) | [scripts/map.js](scripts/map.js) — `dismissRoutePopup()`, `_routePopupTimer`, popup `mouseenter`/`mouseleave` handlers |
| **Route popup meta styling** (event badge, surface tag) | [styles/map.css](styles/map.css) — `.rmm-route-card-meta`, `.rmm-route-card-event`, `.rmm-route-card-surface` |
| **Route popup action link styling** | [styles/map.css](styles/map.css) — `.rmm-route-card-action` (now coral link, not dim text) |

---

## Orphaned / Legacy Files

None. The two pre-launch curtain files (`scripts/main.js`, `styles/main.css`) were deleted on 2026-04-30 (commit `35b6a56 chore: remove orphaned curtain page files`). If a curtain page is ever reintroduced, restore from git history rather than recreating from scratch.
