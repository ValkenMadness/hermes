---
title: website_component_map
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-21
updated_by: claude_cowork
tags: [codebase, website, components, frontend]
supersedes: ""
related: ["[[website_architecture]]", "[[website_key_files]]", "[[website_styling_overview]]", "[[website_styling_patterns_and_animations]]"]
---

# RMM Website Component Map

This document maps every page/route to the exact files that power it. Use this to answer: "if I need to change X, which files do I touch?"

There is no component framework. "Components" here means JavaScript functions that inject HTML, CSS files scoped to a page or group, and sections within HTML files.

---

## How Components Work

The RMM site uses three composition mechanisms:

1. **JS-injected shared components** — `scripts/components.js` runs on every page and injects the nav header (prepended to `<body>`) and footer (appended to `<body>`, skipped on map pages). These are the only true reusable components.
2. **Page HTML files** — each page's unique markup lives in `pages/*.html`. All content sections are inline HTML within the file.
3. **Scoped CSS** — `styles/pages.css` contains all page-specific classes. `styles/components.css` contains shared/nav/footer classes. `styles/map.css` is map-only.

---

## Pages

### `/` — Entry Redirect
| Field | Value |
|---|---|
| File | [index.html](index.html) |
| Styles | none |
| Scripts | none |
| Components | none |
| Data fetched | none |
| State | none |

A bare HTML meta-refresh (`content="0; url=/map"`). No assets loaded. Not a real page.

---

### `/map` — Interactive Map
| Field | Value |
|---|---|
| File | [pages/map.html](pages/map.html) |
| Styles | `mapbox-gl.css` (CDN), [styles/components.css](styles/components.css), [styles/map.css](styles/map.css) |
| Scripts | `mapbox-gl.js` (CDN), [scripts/components.js](scripts/components.js), [scripts/map.js](scripts/map.js) (defer) |
| Components | SiteNav (no footer — explicitly skipped) |

**Data fetched at runtime:**

| Source | What | When |
|---|---|---|
| `GET /api/config` | Mapbox token + style URL + tileset IDs | Map init, before `mapboxgl.Map()` |
| Supabase `style_config` table | Camera overrides (center, zoom, pitch, bearing, terrain exaggeration) | After map style loads; gracefully degraded |
| `/public/data/peaks.geojson` | 65 peak point features | After icons load |
| `/public/data/caves.geojson` | Cave point features | After icons load |
| `/api/python/trails?action=routes` | Live route GeoJSON from Supabase (replaces static files) | After icons load |
| `/api/python/pois?action=map-data` | POI point features from Supabase | After icons load |
| `/public/icons/peaks/*.svg` (×3–4) | Peak marker images | Before layers added |
| `/public/icons/caves/*.svg` (×3–4) | Cave marker images | Before layers added |
| `/public/icons/pois/*.svg` (×28) | POI marker images (14 categories × T1 + T2) | Before POI layers added |

**State:**

| Key | Type | Purpose |
|---|---|---|
| `window.RMMMap` | object | Map module namespace; exposes `init(containerId)` |
| `window._rmmRouteCoords` | array | Merged route coordinates for pulse animation |
| `localStorage.rmm_subscribed` | `'true'` / absent | Suppresses account overlay. Set by: old mailing list signup, platform signup success, or duplicate subscriber detection |
| `localStorage.rmm_admin` | `'true'` / absent | Shows/hides admin-gated nav links |

**Sub-systems inside `map.js` (not separate files):**

| Sub-system | What it does |
|---|---|
| `showEmailOverlay()` | Injects `.rmm-overlay-backdrop` modal, handles form submit to `/api/subscribe` |
| Peak layers | Two Mapbox layers: base (T1→T2 icon swap at zoom 13) + T3 hover layer for bespoke peaks |
| Cave layers | Same pattern as peaks |
| Trail lines | Four Mapbox line layers: footway, path, track, steps — styled from `TRAIL_STYLES` config |
| Contour lines | Two layers: major + minor — styled from `CONTOUR_STYLES` config |
| RMM route lines | Single Mapbox layer from merged `rmm-routes` GeoJSON source |
| Route popup | Custom `.rmm-route-popup` on route line click |
| Hover interactions | `mouseenter`/`mouseleave` for T3 bespoke icons; click-3s on mobile |
| Route pulse | Animated red dot along route (`startRoutePulse(coords)`) |
| Route popup linger | 350ms delay on popup dismissal so users can hover and click "View trail details" link. Timer cancelled on new marker mouseenter. Popup stays alive while hovered. |
| POI layers | Two Mapbox layers per POI category: base (T1→T2 icon swap at zoom 13) + hover layer. 14 categories, 28 SVG icons total. Fetched from `/api/python/pois?action=map-data`. |
| Event type labels | `_eventLabel()` helper maps DB event types (trail, time_trial, hill_climb, hill_bomb) to display labels (Trail Run, Time Trial, Hill Climb, Hill Bomb) for route popups |

---

### `/about` — Platform Story
| Field | Value |
|---|---|
| File | [pages/about.html](pages/about.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | none |
| State | none |

All content is static inline HTML. Sections: hero, the-problem, the-systems, route-grading, RPS, race-readiness, the-map, data-integrity, the-peninsula, the-founder, closing. CSS classes prefixed `.about-*` in `pages.css`.

---

### `/dashboard` — User Hub
| Field | Value |
|---|---|
| File | [pages/dashboard.html](pages/dashboard.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css), [styles/map.css](styles/map.css), `mapbox-gl.css` (CDN) |
| Scripts | [scripts/components.js](scripts/components.js), `mapbox-gl.js` (CDN), [scripts/map.js](scripts/map.js) |
| Components | SiteNav, SiteFooter, Map (embedded panel) |

**Map embed pattern** — inline `<script>` at bottom of body:
```javascript
document.addEventListener('DOMContentLoaded', function() {
    var container = document.getElementById('dashboard-map');
    if (container) {
        window.RMMMap.init('dashboard-map');
    }
});
```
The map renders into `<div id="dashboard-map" class="map-panel-embed">`. The `.map-panel-embed` class in `map.css` switches layout from fixed full-viewport to `position: relative`.

**Data fetched:** Same as `/map` — the map engine runs identically; it fetches config, style_config, GeoJSON, and icons.

**State:** Same as `/map`. `localStorage.rmm_subscribed` suppresses the email overlay; since the overlay is only shown on the `/map` path, it does not appear on `/dashboard`.

**Dashboard panels (currently placeholder content):**
- Row 1: Map panel (left) + Events scroll (right)
- Row 2: Recent Activity (horizontal scroll)
- Row 3: RPS panel, Race Readiness panel, Lifetime Summary panel
- Row 4: Peak Hunter panel, Cave Diver panel

All panels are static HTML shells with no live data wiring yet. CSS classes prefixed `.dash-*` in `pages.css`.

---

### `/intelligence` — Tool Hub
| Field | Value |
|---|---|
| File | [pages/intelligence.html](pages/intelligence.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | none |
| State | none |

Static marketing page for the three intelligence tools. CSS classes prefixed `.intel-*` in `pages.css`.

---

### `/intelligence/fitness` — RPS Detail
| Field | Value |
|---|---|
| File | [pages/intelligence-fitness.html](pages/intelligence-fitness.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | none |
| State | none |

Explains the Running Performance Score: 5 components, weights, 90-day rolling window, athlete level bands. CSS classes `.component-grid`, `.component-card`, `.levels-strip` in `pages.css`.

---

### `/intelligence/rps` — RPS Deep-Dive (NEW 2026-05-11)
| Field | Value |
|---|---|
| File | [pages/intelligence-rps.html](pages/intelligence-rps.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | `/api/auth/session` (auth check), `/api/python/calculate-rps` (live score when Strava connected) |
| State | `RMMAuth` session state |

Full RPS breakdown with live score display. Three-state auth gating. CSS classes prefixed `rps-page-` in `pages.css`.

---

### `/intelligence/routes` — Route Grading Detail (Explainer)
| Field | Value |
|---|---|
| File | [pages/intelligence-routes.html](pages/intelligence-routes.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | none |
| State | none |

Explains the A–F grading scale (+ TDS 1–10). Contains a static validated routes table with 7 example routes. CSS classes `.grade-grid`, `.grade-card`, `.routes-table` in `pages.css`.

---

### `/intelligence/route-grading` — Route Grading Tool (NEW 2026-05-11)
| Field | Value |
|---|---|
| File | [pages/intelligence-route-grading.html](pages/intelligence-route-grading.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | `/api/python/analyze` (public GPX grading), `/api/python/upload` (auth-gated saving, history, toggles, merge) |
| State | `RMMAuth` session state, admin role check |

Interactive route grading tool. Drag-drop GPX upload (public, no auth). Auth-gated saving with admin-only toggles (Show on Map, Include in Readiness). Duplicate detection (haversine <200m start, <10% distance). Route history table. CSS classes prefixed `.rg-*` in `pages.css`.

**Data fetched at runtime:**

| Source | What | When |
|---|---|---|
| `POST /api/python/analyze` | GPX grade result (A–F, TDS, stats, elevation profile) | On GPX file drop/select (no auth) |
| `POST /api/python/upload` (multipart) | Save graded route to Supabase | On "Save" click (auth required) |
| `GET /api/python/upload?action=history&athlete_id=X` | User's route analysis history | On page load (auth required) |
| `POST /api/python/upload` (JSON, action=toggle) | Toggle show_on_map or include_in_readiness | On admin toggle switch (admin only) |
| `POST /api/python/upload` (JSON, action=merge) | Merge duplicate routes | On merge button click (auth required) |

---

### `/intelligence/trail-library` — Trail Library (Admin) (NEW 2026-05-19)
| Field | Value |
|---|---|
| File | [pages/intelligence-trail-library.html](pages/intelligence-trail-library.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css), `mapbox-gl.css` (CDN — for map preview modal) |
| Scripts | [scripts/components.js](scripts/components.js), [scripts/trail-library.js](scripts/trail-library.js), `mapbox-gl.js` (CDN), [scripts/auth.js](scripts/auth.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | `/api/auth/session` (admin auth check), `/api/python/trails?action=create` (GPX upload), `/api/python/trails?action=list-all` (library table), `/api/python/trails?action=segments` (segment editor), `/api/python/trails?action=update-segment` (segment save), `/api/python/trails?action=update` (rename, status toggle), `/api/python/trails?action=snip` (snip tool), `/api/python/trails?action=event-types` (dropdown), `/api/auth/session?type=mapconfig` (map preview token) |
| State | `RMMAuth` session state (admin role required) |

Admin trail management hub. Six functional areas: GPX upload + grading, trail library table with filters and actions, segment editor modal (per-km cards with notes/tags/terrain toggle + scrub bar + snip tool), rename (inline and table), map preview (Mapbox modal), live/draft/archive status toggle.

**CSS prefixes:** `tl-` (trail library), `seg-` (segment editor), `rg-` (grade display reuse) in `pages.css`.

**Data fetched at runtime:**

| Source | What | When |
|---|---|---|
| `GET /api/auth/session` | Admin auth check | Page load — gates all content |
| `POST /api/python/trails?action=create` (multipart) | GPX upload → grade → save draft | On GPX file drop/select |
| `GET /api/python/trails?action=list-all` | All trails (all statuses) for library table | Page load + after actions |
| `GET /api/python/trails?action=event-types` | Event type dropdown options | Page load |
| `GET /api/python/trails?action=segments&trail_id=X` | Per-km segments for a trail | On "Segments" button click |
| `POST /api/python/trails?action=update-segment` | Save segment edits (notes, tags, terrain) | On segment card save |
| `POST /api/python/trails?action=update` | Status toggle, rename, archive | On action button click |
| `POST /api/python/trails?action=snip` | Extract km range as new draft | On snip tool submit |
| `GET /api/auth/session?type=mapconfig` | Mapbox token for map preview | On "View on Map" click |

---

### `/intelligence/poi-manager` — POI Manager (Admin) (NEW 2026-05-19)
| Field | Value |
|---|---|
| File | [pages/intelligence-poi-manager.html](pages/intelligence-poi-manager.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css), `mapbox-gl.css` (CDN — for map preview) |
| Scripts | [scripts/components.js](scripts/components.js), [scripts/poi-manager.js](scripts/poi-manager.js), `mapbox-gl.js` (CDN), [scripts/auth.js](scripts/auth.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | `/api/auth/session` (admin auth check), `/api/python/pois?action=list` (POI library), `/api/python/pois?action=create` (create POI), `/api/python/pois?action=update` (edit POI), `/api/python/pois?action=delete` (delete POI), `/api/auth/session?type=mapconfig` (map preview token) |
| State | `RMMAuth` session state (admin role required) |

Admin POI management with full CRUD. Features: 14-category dropdown, coordinate entry (supports DDM format like `S 34° 5.328' E 18° 24.662'` auto-parsed to decimal), elevation, description, map preview modal, POI library table with category filters.

**CSS prefixes:** `poi-` in `pages.css`.

**Data fetched at runtime:**

| Source | What | When |
|---|---|---|
| `GET /api/auth/session` | Admin auth check | Page load — gates all content |
| `GET /api/python/pois?action=list` | All POIs for library table | Page load + after CRUD actions |
| `POST /api/python/pois?action=create` | Create new POI | On form submit |
| `POST /api/python/pois?action=update` | Edit existing POI | On edit form submit |
| `POST /api/python/pois?action=delete` | Delete POI | On delete button (with confirmation) |
| `GET /api/auth/session?type=mapconfig` | Mapbox token for map preview | On "View on Map" click |

---

### `/intelligence/readiness` — Race Readiness Detail
| Field | Value |
|---|---|
| File | [pages/intelligence-readiness.html](pages/intelligence-readiness.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | none |
| State | none |

Explains the 5 readiness checks and 3 verdicts (READY / CLOSE / NOT YET). CSS classes `.checks-grid`, `.verdicts-strip`, `.verdict-card`, `.verdict-ready/close/notyet` in `pages.css`.

---

### `/leaderboards` — Leaderboards
| Field | Value |
|---|---|
| File | [pages/leaderboards.html](pages/leaderboards.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | none |
| State | none |

Static coming-soon page. Contains placeholder leaderboard table. CSS classes `.leaderboard-types`, `.leaderboard-table` in `pages.css`.

---

### `/event` — Event Detail
| Field | Value |
|---|---|
| File | [pages/event.html](pages/event.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | none |
| State | none |

Single static event template (example: "Chase the Dragons Tail"). Two-column layout: event details left, map preview + elevation profile right. CSS classes `.event-layout`, `.event-grade-badge`, `.event-tiers` in `pages.css`.

---

### `/shop` — Shop Grid
| Field | Value |
|---|---|
| File | [pages/shop.html](pages/shop.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | none |
| State | none |

4-product grid, all "coming soon". CSS classes `.shop-grid`, `.product-card` in `pages.css`.

---

### `/product` — Product Detail
| Field | Value |
|---|---|
| File | [pages/product.html](pages/product.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | none |
| State | none |

Single product template (Cape Peninsula Trail Map, R495–R695). Two-column layout. CSS classes `.product-layout`, `.product-details`, `.product-pricing` in `pages.css`.

---

### `/trails` — Trail Browse (Public) (NEW 2026-05-19)
| Field | Value |
|---|---|
| File | [pages/trails.html](pages/trails.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js), [scripts/trail-browse.js](scripts/trail-browse.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | `/api/python/trails?action=browse` (lightweight trail list) |
| State | none |

Public trail browse page. Fetches live trails (seasonal filtering server-side), renders as card grid. Client-side filters: grade (A–F), event type (Trail Run, Time Trial, Hill Climb, Hill Bomb), sort (name, distance, grade, elevation gain). Cards show grade badge, event type label, distance, elevation gain, density, effort descriptor, and link to trail detail page. Loading spinner and empty-state messaging.

**CSS prefixes:** `tb-` (trail browse) in `pages.css`.

**Data fetched at runtime:**

| Source | What | When |
|---|---|---|
| `GET /api/python/trails?action=browse` | Lightweight trail metadata (no coordinates) | Page load |

---

### `/trail/:slug` — Trail Detail (Public) (NEW 2026-05-19)
| Field | Value |
|---|---|
| File | [pages/trail.html](pages/trail.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css), `mapbox-gl.css` (CDN — for mini-map) |
| Scripts | [scripts/components.js](scripts/components.js), [scripts/trail-detail.js](scripts/trail-detail.js), `mapbox-gl.js` (CDN) |
| Components | SiteNav, SiteFooter |
| Data fetched | `/api/python/trails?action=get-trail&slug=X` (full trail data + segments + linked POIs), `/api/auth/session?type=mapconfig` (Mapbox token for mini-map) |
| State | none |

Public trail detail view. Renders: event type badge, trail name, grade letter (colour-coded A–F), TDS score, distance/gain/loss/density/effort stats, surface breakdown (trail % vs road %), composite climb/descent grade cards, description, SVG elevation profile, interactive Mapbox mini-map with trail line + start/end markers, per-km segment cards, and linked POI list with category icons.

**CSS prefixes:** `td-` (trail detail) in `pages.css`.

**Data fetched at runtime:**

| Source | What | When |
|---|---|---|
| `GET /api/python/trails?action=get-trail&slug=X` | Full trail data, segments, linked POIs | Page load (slug extracted from URL path) |
| `GET /api/auth/session?type=mapconfig` | Mapbox token + style URL for mini-map | After trail data loads |

---

### `/404` — Not Found (NEW 2026-05-19)
| Field | Value |
|---|---|
| File | [pages/404.html](pages/404.html) (also copied to project root `404.html` for Vercel auto-serving) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav (no footer — minimal error page) |
| Data fetched | none |
| State | none |

On-brand error page with "404" code, "Trail not found" heading, "You've gone off the map" subtext, and back-to-map link. Vercel auto-serves the root-level `404.html` for any unmatched routes.

**CSS prefixes:** `.error-` in `pages.css`.

---

### `/privacy`, `/terms`, `/cookies`, `/acceptable-use`, `/legal` — Legal Pages

All five pages follow the identical pattern:

| Field | Value |
|---|---|
| Files | [pages/privacy.html](pages/privacy.html), [pages/terms.html](pages/terms.html), [pages/cookies.html](pages/cookies.html), [pages/acceptable-use.html](pages/acceptable-use.html), [pages/legal.html](pages/legal.html) |
| Styles | [styles/components.css](styles/components.css), [styles/pages.css](styles/pages.css) |
| Scripts | [scripts/components.js](scripts/components.js) |
| Components | SiteNav, SiteFooter |
| Data fetched | none |
| State | none |

All static prose content only. No page-specific CSS classes — styled by base `.page-content`, `.section` rules in `components.css`.

---

## Shared Components

### SiteNav
| Field | Value |
|---|---|
| File | [scripts/components.js](scripts/components.js) — `renderNav()` function |
| CSS | [styles/components.css](styles/components.css) — `.site-nav`, `.nav-inner`, `.nav-logo`, `.nav-brand`, `.nav-links`, `.nav-link`, `.nav-toggle` |
| Used on | Every page |

Prepended to `<body>` via `document.body.prepend(nav)`. Creates `<header class="site-nav">`.

**What it renders:**
- Logo (SVG) + "RUN MAD MAPS" brand text — links to `/`
- Nav links (always visible): Map (`/`), Trails (`/trails`), About (`/about`)
- Nav links (admin-gated): Shop, Intelligence (with dropdown), Leaderboards, Dashboard — shown only when `localStorage.rmm_admin === 'true'`
- **Intelligence dropdown (updated 2026-05-19):** `.nav-dropdown` wrapper around Intelligence link with `.nav-dropdown-menu` containing five `.nav-dropdown-item` sub-links: Fitness Score (RPS) → `/intelligence/rps`, Route Grading Tool → `/intelligence/route-grading`, Race Readiness → `/intelligence/race-readiness`, Trail Library → `/intelligence/trail-library`, POI Manager → `/intelligence/poi-manager`. Desktop: shows on hover. Mobile: click-to-toggle via `.nav-dropdown.open` class.
- Mobile hamburger toggle (activates `.open` class on `.nav-links`)
- Active link highlighting: matches `window.location.pathname`; treats `/map` and `/` as equivalent

**To change nav links:** edit `renderNav()` in [scripts/components.js](scripts/components.js)  
**To change nav styling:** edit `.site-nav` rules in [styles/components.css](styles/components.css)  
**To change dropdown items:** edit the dropdown HTML in `renderNav()` or the `dropdown` array in `addAdminNavLinks()`  
**To change dropdown styling:** edit `.nav-dropdown`, `.nav-dropdown-menu`, `.nav-dropdown-item` in [styles/components.css](styles/components.css)

---

### SiteFooter
| Field | Value |
|---|---|
| File | [scripts/components.js](scripts/components.js) — `renderFooter()` function |
| CSS | [styles/components.css](styles/components.css) — `.site-footer`, `.footer-inner`, `.footer-brand`, `.footer-logo`, `.footer-tagline`, `.footer-links`, `.footer-legal`, `.footer-legal-links` |
| Used on | All pages except `/` and `/map` |

Appended to `<body>` via `document.body.appendChild(footer)`. Skipped when `pathname === '/'` or `pathname === '/map'`.

**What it renders:**
- Logo (SVG) + tagline
- Nav links: Map, Trails, About (always visible) + Shop, Intelligence, Leaderboards, Dashboard (admin-gated, same logic as SiteNav)
- Legal link row: Privacy Policy, Terms, Cookie Policy, Acceptable Use
- Copyright year (dynamic: `new Date().getFullYear()`) + "Cape Town, South Africa"

**To change footer content:** edit `renderFooter()` in [scripts/components.js](scripts/components.js)  
**To change footer styling:** edit `.site-footer` rules in [styles/components.css](styles/components.css)

---

### Map Engine (`window.RMMMap`)
| Field | Value |
|---|---|
| File | [scripts/map.js](scripts/map.js) |
| CSS | [styles/map.css](styles/map.css) |
| Used on | `/map` (full-page), `/dashboard` (panel-embed via `window.RMMMap.init('dashboard-map')`) |

The map is a self-contained module exported to `window.RMMMap`. It has no imports and no dependencies on other RMM scripts.

**Entry point:** `window.RMMMap.init(containerId)` — accepts any DOM element ID.

**Key config objects inside map.js** (the primary editing targets):

| Object | Location | What it controls |
|---|---|---|
| `DEFAULTS` | top of file | Default camera: center, zoom, pitch, bearing, terrainExaggeration |
| `TRAIL_STYLES` | top of file | Color, width, dash pattern, opacity for each trail type |
| `CONTOUR_STYLES` | top of file | Colors and widths for major/minor contour lines |
| `MARKER_STYLES` | top of file | Icon files, sizes, zoom thresholds for peaks + caves; bespoke overrides |
| `RMM_ROUTES` | top of file | Array of GeoJSON route file paths to load |

**To add a new bespoke peak icon:** Add an entry to `MARKER_STYLES.peaks.bespoke` + add the SVG to `/public/icons/peaks/`.  
**To add a new route:** Add the GeoJSON file path to the `RMM_ROUTES` array.  
**To change map camera defaults:** Edit `DEFAULTS` in `map.js`, or override via Supabase `style_config` table (takes effect without a code deploy).

---

### Account Signup Overlay (formerly Email Signup Overlay)
| Field | Value |
|---|---|
| File | [scripts/map.js](scripts/map.js) — `initEmailOverlay()` (embedded, not a separate module) |
| CSS | [styles/map.css](styles/map.css) — `.rmm-overlay-backdrop`, `.rmm-overlay-card`, `.rmm-overlay-submit`, `.rmm-overlay-cta-link`, `.rmm-overlay-dismiss` |
| Used on | `/map` only |
| API call | None (no form submission — CTA links to `/signup` when live) |

**Changed 2026-05-09:** Replaced the mailing list signup form with a "Create Free Account" prompt. No longer collects email inline — instead directs users to the signup page.

**Activation:** Controlled by `RMM_OVERLAY_LIVE` flag at top of `map.js`. When `false`, CTA reads "Coming Soon" and is disabled. When `true`, CTA links to `/signup`.

**Suppression:** Overlay hidden when ANY of these are true:
- `localStorage.rmm_subscribed === 'true'` (set on signup success or old mailing list signup)
- `document.cookie` contains `rmm_session` (user is logged in)

**To change overlay copy:** edit `initEmailOverlay()` in [scripts/map.js](scripts/map.js)
**To change overlay styling:** edit `.rmm-overlay-*` rules in [styles/map.css](styles/map.css)
**To go live:** set `RMM_OVERLAY_LIVE = true` in [scripts/map.js](scripts/map.js)

---

## Orphaned Files (Not Currently Loaded by Any Page)

These files exist in the repo but are not referenced by any HTML page. They are legacy artifacts from an earlier landing-page concept.

| File | Status | Notes |
|---|---|---|
| [scripts/main.js](scripts/main.js) | Orphaned | Landing page form logic + admin bypass gate. The admin bypass gate was duplicated into `components.js`. The form targets DOM IDs (`#nameInput`, `#emailInput`, etc.) that exist in no current HTML file. |
| [styles/main.css](styles/main.css) | Orphaned | Styles for `.landing`, `.curtain`, `.admin-nav`, and form elements from the old landing page. Not loaded by any page. |

If a pre-launch curtain page is reintroduced, these files would be the starting point. Until then, do not modify them expecting it to affect the live site.

---

## "Which files do I touch?" Quick Reference

| Task | Files to edit |
|---|---|
| Change nav links or order | [scripts/components.js](scripts/components.js) — `renderNav()` |
| Change footer links or copyright | [scripts/components.js](scripts/components.js) — `renderFooter()` |
| Change nav/footer visual styling | [styles/components.css](styles/components.css) |
| Change global color palette or fonts | [styles/components.css](styles/components.css) — `:root` CSS variables |
| Add or remove a page | Create `pages/newpage.html` + add rewrite in [vercel.json](vercel.json) |
| Change page section styling | [styles/pages.css](styles/pages.css) |
| Change map camera defaults (code) | [scripts/map.js](scripts/map.js) — `DEFAULTS` object |
| Change map camera defaults (no deploy) | Supabase `style_config` table |
| Change trail line colors or widths | [scripts/map.js](scripts/map.js) — `TRAIL_STYLES` object |
| Change contour line styling | [scripts/map.js](scripts/map.js) — `CONTOUR_STYLES` object |
| Add a bespoke peak/cave icon | [scripts/map.js](scripts/map.js) — `MARKER_STYLES.[peaks\|caves].bespoke` + SVG file in `/public/icons/` |
| Change peak/cave marker zoom threshold | [scripts/map.js](scripts/map.js) — `MARKER_STYLES.[peaks\|caves].iconSwitch` |
| Add a new graded route | Routes now come from Supabase via `/api/python/trails?action=routes` — use Trail Library admin page to upload GPX |
| Change route popup content | [scripts/map.js](scripts/map.js) — route popup HTML section |
| Add/edit a POI | Use POI Manager admin page (`/intelligence/poi-manager`). POIs stored in Supabase, rendered from API. |
| Add a new POI category | Add SVG icons to `/public/icons/pois/`, update `POI_CATEGORIES` in [scripts/poi-manager.js](scripts/poi-manager.js) and [scripts/trail-detail.js](scripts/trail-detail.js), update POI layer setup in [scripts/map.js](scripts/map.js) |
| Change account overlay copy or layout | [scripts/map.js](scripts/map.js) — `initEmailOverlay()` HTML string |
| Change account overlay styling | [styles/map.css](styles/map.css) — `.rmm-overlay-*` rules |
| Go live with account signup overlay | [scripts/map.js](scripts/map.js) — set `RMM_OVERLAY_LIVE = true` |
| Change map control (zoom/compass) styling | [styles/map.css](styles/map.css) — `.mapboxgl-ctrl-*` rules |
| Change Mapbox style | Mapbox Studio + update `MAPBOX_STYLE_URL` env var |
| Change about page content | [pages/about.html](pages/about.html) |
| Change dashboard panel layout | [pages/dashboard.html](pages/dashboard.html) + [styles/pages.css](styles/pages.css) — `.dash-*` rules |
| Change trail browse filters or cards | [scripts/trail-browse.js](scripts/trail-browse.js) + [styles/pages.css](styles/pages.css) — `.tb-*` rules |
| Change trail detail layout | [scripts/trail-detail.js](scripts/trail-detail.js) + [pages/trail.html](pages/trail.html) + [styles/pages.css](styles/pages.css) — `.td-*` rules |
| Embed map on a new page | Load `mapbox-gl.js`, [scripts/map.js](scripts/map.js), [styles/map.css](styles/map.css) in the page; add `<div id="my-id" class="map-panel-embed">` + call `window.RMMMap.init('my-id')` |
| Add security headers | [vercel.json](vercel.json) |

---

## Dependency Graph

```
Every page
  └── scripts/components.js
        ├── renderNav() → styles/components.css (.site-nav)
        └── renderFooter() → styles/components.css (.site-footer)
              [skipped on / and /map]

/map  (pages/map.html)
  ├── mapbox-gl.js [CDN]
  ├── mapbox-gl.css [CDN]
  ├── styles/components.css
  ├── styles/map.css
  ├── scripts/components.js
  └── scripts/map.js
        ├── fetches /api/config → Mapbox token + style URL
        ├── fetches Supabase style_config → camera overrides
        ├── fetches /public/data/peaks.geojson
        ├── fetches /public/data/caves.geojson
        ├── fetches /public/data/routes/*.geojson (×8)
        ├── fetches /public/icons/peaks/*.svg
        ├── fetches /public/icons/caves/*.svg
        └── POSTs /api/subscribe (email overlay)

/dashboard  (pages/dashboard.html)
  ├── [same as /map above]
  └── inline script: window.RMMMap.init('dashboard-map')

/intelligence/trail-library  (pages/intelligence-trail-library.html)
  ├── mapbox-gl.js [CDN] (for map preview modal)
  ├── mapbox-gl.css [CDN]
  ├── styles/components.css
  ├── styles/pages.css
  ├── scripts/components.js
  ├── scripts/auth.js
  └── scripts/trail-library.js
        ├── POSTs /api/python/trails?action=create (GPX upload)
        ├── GETs /api/python/trails?action=list-all (library table)
        ├── GETs /api/python/trails?action=segments (segment editor)
        ├── POSTs /api/python/trails?action=update (status/rename)
        ├── POSTs /api/python/trails?action=update-segment (segment save)
        ├── POSTs /api/python/trails?action=snip (snip tool)
        └── GETs /api/auth/session?type=mapconfig (map preview token)

/intelligence/poi-manager  (pages/intelligence-poi-manager.html)
  ├── mapbox-gl.js [CDN] (for map preview)
  ├── mapbox-gl.css [CDN]
  ├── styles/components.css
  ├── styles/pages.css
  ├── scripts/components.js
  ├── scripts/auth.js
  └── scripts/poi-manager.js
        ├── GETs /api/python/pois?action=list (POI library)
        ├── POSTs /api/python/pois?action=create|update|delete
        └── GETs /api/auth/session?type=mapconfig (map preview token)

/trails  (pages/trails.html)
  ├── styles/components.css
  ├── styles/pages.css
  ├── scripts/components.js
  └── scripts/trail-browse.js
        └── GETs /api/python/trails?action=browse (lightweight trail list)

/trail/:slug  (pages/trail.html)
  ├── mapbox-gl.js [CDN] (for mini-map)
  ├── mapbox-gl.css [CDN]
  ├── styles/components.css
  ├── styles/pages.css
  ├── scripts/components.js
  └── scripts/trail-detail.js
        ├── GETs /api/python/trails?action=get-trail&slug=X
        └── GETs /api/auth/session?type=mapconfig (mini-map token)

All other pages
  ├── styles/components.css
  ├── styles/pages.css
  └── scripts/components.js
```
