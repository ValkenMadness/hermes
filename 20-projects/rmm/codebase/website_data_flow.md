---
title: website_data_flow
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-21
updated_by: claude_cowork
tags: [codebase, website, data, api, supabase]
supersedes: ""
related: ["[[website_architecture]]", "[[data_architecture]]", "[[website_deployment_and_devops]]"]
---

# RMM Website — Data Flow

This document traces every data source, every request, and every failure path in the application. Most pages are static HTML, but the map, dashboard, and intelligence tool pages (`/intelligence/fitness`, `/intelligence/routes`, `/intelligence/route-grading`, `/intelligence/rps`, `/intelligence/readiness`) fetch data at runtime.

---

## 1. Data Sources

| Source | Type | What it contains | Who reads it |
|---|---|---|---|
| `/public/data/peaks.geojson` | Static file (Vercel CDN) | 65 peak point features | Mapbox GL (via `addSource`) |
| `/public/data/caves.geojson` | Static file (Vercel CDN) | Cave entrance point features | Mapbox GL (via `addSource`) |
| `/api/python/trails?action=routes` | Supabase via serverless | Live route GeoJSON (replaces static route files) | `map.js` — `loadRMMRoutes()` |
| `/api/python/pois?action=map-data` | Supabase via serverless | POI point features for map markers | `map.js` — POI layer setup |
| `/public/icons/**/*.svg` | Static file (Vercel CDN) | Marker icon SVGs (T1–T3 for peaks/caves, T1–T2 for POIs) | `map.js` — `loadSVGAsMapIcon()` |
| Supabase `style_config` table | PostgreSQL via REST | Map camera configuration key-value rows | `map.js` — `loadStyleConfig()` |
| Supabase `subscribers` table | PostgreSQL via REST | Email subscriber records | `api/subscribe.js` (write only) |
| Vercel env vars | Server process environment | Mapbox token, style URL, tileset IDs, Supabase keys | `api/config.js`, `api/subscribe.js` |
| Mapbox tiles | Third-party CDN (Mapbox) | Map raster/vector tiles, DEM terrain | Mapbox GL JS runtime |
| Google Fonts CDN | Third-party CDN | Space Mono typeface | Every page `<head>` |

---

## 2. API Endpoints

### `GET /api/config`

**File:** [api/config.js](api/config.js)  
**Module format:** CommonJS (`module.exports = function handler`)  
**Purpose:** Securely deliver the Mapbox access token and related config to the client without exposing them in source code.

**Request:**
```
GET /api/config
```
No body, no query parameters, no authentication required.

**Response (200):**
```json
{
  "token":             "pk.eyJ1...",
  "styleUrl":          "mapbox://styles/valkenmadness/cmnsvhzns002701qwc1xshumo",
  "trailsTilesetId":   "",
  "contoursTilesetId": ""
}
```

`trailsTilesetId` and `contoursTilesetId` default to `""` (empty string) if the env vars are unset. The map engine treats empty string as "layer disabled".

**Response (500):**
```json
{ "error": "Map configuration unavailable." }
```
Returned when `MAPBOX_PUBLIC_TOKEN` or `MAPBOX_STYLE_URL` env vars are missing.

**CORS:** Restricts `Access-Control-Allow-Origin` to `https://runmadmaps.com` and `http://localhost:3000` only. Other origins receive the JSON body but without the CORS header, causing a cross-origin browser block.

**CORS note:** The header is only set if `req.headers.origin` is in the allowlist. A direct server-to-server call (no `Origin` header) receives the JSON without CORS headers — this is fine.

---

### `POST /api/subscribe`

**File:** [api/subscribe.js](api/subscribe.js)  
**Module format:** ES Modules (`export default async function handler`)  
**Purpose:** Capture email subscriptions and write to the Supabase `subscribers` table.

**CORS:**
```
Access-Control-Allow-Origin:  https://runmadmaps.com
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
```
`OPTIONS` preflight requests return `200` immediately.

**Request:**
```
POST /api/subscribe
Content-Type: application/json

{
  "name":   "Jane Runner",
  "email":  "jane@example.com",
  "source": "map-overlay"      ← optional; defaults to "landing_page" if absent
}
```

**Server-side validation (in order):**
1. `name` present and non-empty after trim → 400 `"Name is required."`
2. `email` present → 400 `"Email is required."`
3. `email` matches `/^[^\s@]+@[^\s@]+\.[^\s@]+$/` → 400 `"Invalid email format."`
4. `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` env vars present → 500 `"Server configuration error."`

**Source sanitization:**
```javascript
source = rawSource.replace(/[^a-zA-Z0-9_\-]/g, '').slice(0, 64) || 'landing_page'
```
Non-alphanumeric characters stripped. Max 64 chars. Defaults to `'landing_page'` if result is empty.

**Email normalization:** `email.trim().toLowerCase()` before insert.

**Supabase insert:**
```http
POST /rest/v1/subscribers
apikey: SUPABASE_SERVICE_ROLE_KEY
Authorization: Bearer SUPABASE_SERVICE_ROLE_KEY
Prefer: return=minimal
Content-Type: application/json

{ "email": "...", "first_name": "...", "consent_given": true, "source": "..." }
```

`Prefer: return=minimal` tells Supabase not to return the inserted row — saves bandwidth, reduces response time.

**Response codes:**

| HTTP | Body | Meaning |
|---|---|---|
| `200` | `{ "success": true }` | Inserted successfully |
| `400` | `{ "error": "..." }` | Validation failed |
| `405` | `{ "error": "Method not allowed" }` | Non-POST, non-OPTIONS request |
| `409` | `{ "error": "Already subscribed." }` | Supabase unique constraint on `email` |
| `500` | `{ "error": "..." }` | Missing env vars or Supabase error |

---

## 3. Client-Side Data Fetching

Map data fetching lives in [scripts/map.js](scripts/map.js). Other scripts that fetch data: [scripts/trail-browse.js](scripts/trail-browse.js) (trail browse page), [scripts/trail-detail.js](scripts/trail-detail.js) (trail detail page), [scripts/trail-library.js](scripts/trail-library.js) (admin trail library), [scripts/poi-manager.js](scripts/poi-manager.js) (admin POI manager). The map fetch sequence is strictly ordered.

### Complete Fetch Sequence (map page)

```
DOMContentLoaded fires
│
├─ [1] fetch('/api/config')                    ← BLOCKING — map cannot init without this
│       Returns: token, styleUrl, tileset IDs
│       On success: new mapboxgl.Map(...)
│       On failure: showMapError() — stops here
│
└─ map.on('load') fires
        │
        ├─ [2] loadAllMarkerIcons()             ← BLOCKING for layer creation
        │       fetch('/public/icons/peaks/t1-peak-generic.svg')
        │       fetch('/public/icons/peaks/t2-peak-generic.svg')
        │       fetch('/public/icons/peaks/t3-peak-maclears-beacon.svg')
        │       fetch('/public/icons/caves/t1-cave-generic.svg')
        │       fetch('/public/icons/caves/t2-cave-generic.svg')
        │       fetch('/public/icons/caves/t3-cave-boomslang-cave.svg')
        │       All in parallel via Promise.all()
        │
        ├─ [3] addDataLayers()                  ← BLOCKING for interactivity
        │       └─ addSource('peaks', '/public/data/peaks.geojson')     ← Mapbox fetches
        │          addSource('caves', '/public/data/caves.geojson')     ← Mapbox fetches
        │          loadRMMRoutes()
        │            fetch('/public/data/routes/Elsies-Peak-Route-1.geojson')
        │            fetch('/public/data/routes/Elsies-Peak-Route-2.geojson')
        │            fetch('/public/data/routes/Elsies-Peak-Route-3.geojson')
        │            fetch('/public/data/routes/Silvermine-Lower-Route-1.geojson')
        │            fetch('/public/data/routes/Silvermine-Lower-Route-2.geojson')
        │            fetch('/public/data/routes/Silvermine-Lower-Route-3.geojson')
        │            fetch('/public/data/routes/Silvermine-Lower-Route-4.geojson')
        │            fetch('/public/data/routes/Silvermine-Lower-Route-5.geojson')
        │            ← Sequential (for loop + await), not parallel
        │
        ├─ [4] loadStyleConfig()               ← NON-BLOCKING — fire and forget
        │       fetch(SUPABASE_URL + '/rest/v1/style_config?select=key,value')
        │       Headers: { apikey: SUPABASE_ANON_KEY }
        │       On success: map.easeTo() with any camera overrides
        │       On failure: silently ignored
        │
        └─ window.rmmMapReady = true
```

### Triggered by User Action

```
User creates account (signup page)
│
└─ POST /api/auth/account?action=signup
        Creates user in `users` table
        Auto-inserts into `subscribers` table (source: 'platform-signup')
        Sets session cookie
        Client sets localStorage.rmm_subscribed = 'true'
        Shows race number reveal card

Map overlay (account prompt)
│
└─ No form submission — overlay shows "Coming Soon" (disabled CTA)
        When RMM_OVERLAY_LIVE = true, CTA links to /signup
        Suppressed if localStorage.rmm_subscribed = 'true' OR rmm_session cookie exists
```

### Fetch Parallelism

| Fetch group | Parallel or sequential |
|---|---|
| Marker icons (6 SVG files) | **Parallel** — `Promise.all()` |
| Route GeoJSON (8 files) | **Sequential** — `for` loop with `await` |
| Peaks + Caves GeoJSON | **Parallel** — Mapbox GL loads both sources concurrently |
| `/api/config` vs Supabase | **Sequential** — config must succeed before map init; style_config loads after |

Route files are sequential by choice: avoids 8 simultaneous fetches from the same domain, which can queue up under HTTP/1.1 connection limits. At current scale (8 files, ~160KB total) this is acceptable.

---

## 4. Supabase Integration

### Client Access (read-only, no SDK)

**Used in:** [scripts/map.js](scripts/map.js)

```javascript
const SUPABASE_URL = 'https://lpzppqveekozdvqdduqg.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_ZVySCQwBHfooIiMMQa3Otg_OxPPMDE8';
```

Both values are hardcoded in the client-side script. This is the Supabase-recommended pattern for the anon key — it is a **publishable** key scoped to row-level security (RLS) policies and carries no elevated privileges. It is equivalent to an API key on a public read endpoint.

**Query:**
```javascript
fetch(SUPABASE_URL + '/rest/v1/style_config?select=key,value', {
    headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Content-Type': 'application/json'
    }
})
```

Returns an array of `{ key: string, value: string }` rows. No authentication header — the anon key is passed as `apikey` only.

### Server Access (write, no SDK)

**Used in:** [api/subscribe.js](api/subscribe.js)

```javascript
var supabaseUrl = process.env.SUPABASE_URL;
var supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

fetch(supabaseUrl + '/rest/v1/subscribers', {
    method: 'POST',
    headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer ' + supabaseKey,
        'Prefer': 'return=minimal',
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({ email, first_name, consent_given: true, source })
})
```

The service role key is passed as both `apikey` and `Authorization: Bearer`. This is the Supabase convention for server-side writes — the service role key bypasses all RLS policies.

### No Supabase JS SDK

Neither the client nor the server imports `@supabase/supabase-js`. All Supabase interaction is raw `fetch()` to the REST API. This avoids an npm dependency and keeps the bundle size at zero.

### Tables

**`style_config`** (read by `map.js`)

| Column | Type | Purpose |
|---|---|---|
| `key` | text | Config key name |
| `value` | text | Config value (always stored as text, parsed to float where needed) |

Keys currently consumed by the map:

| Key | Effect if present |
|---|---|
| `map_center_lng` | Override default longitude (paired with `map_center_lat`) |
| `map_center_lat` | Override default latitude |
| `map_zoom` | Override default zoom level |
| `map_pitch` | Override camera pitch |
| `map_bearing` | Override camera bearing |
| `terrain_exaggeration` | Override 3D terrain height multiplier |

All values are parsed with `parseFloat()`. Missing keys are silently skipped.

**`subscribers`** (written by `api/subscribe.js`)

| Column | Type | Written value |
|---|---|---|
| `email` | text, UNIQUE | Lowercased, trimmed email address |
| `first_name` | text | Trimmed name from form |
| `consent_given` | boolean | Always `true` (server enforces this — client cannot send false) |
| `source` | text | Sanitized source tag: `'map-overlay'`, `'landing_page'`, or custom |
| `created_at` | timestamp | Supabase default (not sent by client) |

The `UNIQUE` constraint on `email` causes Supabase to return HTTP `409` on duplicate inserts, which the API propagates to the client as `{ error: 'Already subscribed.' }`.

### RLS Policies

RLS policy configuration lives in the Supabase dashboard and is not visible in this codebase. Based on observed behaviour:
- `style_config`: readable by the anon key (public read, no auth required)
- `subscribers`: not directly readable by the anon key; writes use the service role key which bypasses RLS

---

## 5. Caching Strategy

There is no explicit caching layer configured in this project. The following describes what each layer does by default.

### Static File CDN (Vercel)

GeoJSON files in `/public/data/` and SVG icons in `/public/icons/` are served by Vercel's global CDN. Vercel applies `Cache-Control: public, max-age=0, must-revalidate` to static assets by default unless overridden in `vercel.json`. No custom cache headers are set in this project, so GeoJSON and SVG files use Vercel's default policy.

In practice: assets are edge-cached across Vercel's CDN nodes; a `git push` deployment invalidates the cache automatically. Users always receive the current version after a deploy.

### Serverless Function Responses

`/api/config` and `/api/subscribe` are serverless functions. Vercel does not cache serverless function responses by default. Every request hits the function. No `Cache-Control` headers are set on responses.

This means `/api/config` is called on every map init, every page load. At current traffic scale this is acceptable. If token delivery becomes a performance concern, adding `Cache-Control: public, max-age=3600` to the `/api/config` response would cache it at the edge.

### Browser-Side In-Memory Cache

`window._rmmRouteCoords` — the merged route coordinate arrays stored at load time. This is an in-memory session cache; it persists for the lifetime of the page and is used to avoid calling `map.querySourceFeatures()` (which returns tile-clipped partial arrays) on every hover event.

### Browser-Side Persistent Cache (`localStorage`)

| Key | Value | Purpose | TTL |
|---|---|---|---|
| `localStorage.rmm_subscribed` | `'true'` | Suppresses the email signup overlay permanently once a user has subscribed | None — persists indefinitely |
| `localStorage.rmm_admin` | `'true'` | Unlocks admin-gated nav links | None — persists until `?admin=reset` is visited |

No `sessionStorage` is used. No `IndexedDB`. No service worker. No offline caching.

### Mapbox Tile Cache

Mapbox GL JS caches tiles in the browser's HTTP cache via standard cache headers set by Mapbox's CDN. The map application has no control over this.

---

## 6. Environment Variables

All secrets are injected via environment variables. They are never committed to the repository.

**Local development:** Defined in [.env](.env) (excluded from git via `.gitignore`). Template at [.env.example](.env.example).

**Production:** Set in the Vercel dashboard under Project → Settings → Environment Variables.

| Variable | Used in | Purpose |
|---|---|---|
| `MAPBOX_PUBLIC_TOKEN` | [api/config.js](api/config.js) | Mapbox GL JS access token — delivered to client at map init |
| `MAPBOX_STYLE_URL` | [api/config.js](api/config.js) | Mapbox Studio style URL — delivered to client at map init |
| `TRAILS_TILESET_ID` | [api/config.js](api/config.js) | Mapbox tileset ID for trail lines — delivered to client; empty string disables trail layer |
| `CONTOURS_TILESET_ID` | [api/config.js](api/config.js) | Mapbox tileset ID for contour lines — delivered to client; empty string disables contour layer |
| `SUPABASE_URL` | [api/subscribe.js](api/subscribe.js) | Supabase project REST URL (`https://[project-ref].supabase.co`) — server-side write access |
| `SUPABASE_SERVICE_ROLE_KEY` | [api/subscribe.js](api/subscribe.js) | Supabase service role key — bypasses RLS; used only server-side for subscriber inserts |

**Note on `SUPABASE_URL` and `SUPABASE_ANON_KEY`:** These are also hardcoded in [scripts/map.js](scripts/map.js) as constants at the top of the file:

```javascript
const SUPABASE_URL = 'https://lpzppqveekozdvqdduqg.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_ZVySCQwBHfooIiMMQa3Otg_OxPPMDE8';
```

The anon key is intentionally in source — it is a publishable read-only key governed by RLS, equivalent to a public API key. The `SUPABASE_URL` in `map.js` must stay in sync with the env var used in `api/subscribe.js`.

---

## 7. Error Handling

### Map Init — `/api/config` Fails

**Trigger:** Network error, Vercel function crash, or missing env vars.

**Handler:** `initMap()` `.catch()` block:
```javascript
.catch(function() {
    showMapError(targetId);
});
```

**`showMapError(containerId)`** replaces the map container's innerHTML with:
```html
<div class="map-error-state">
    <strong>RUN MAD MAPS</strong>
    <p>Map unavailable. Please try again shortly.</p>
</div>
```

The page remains functional (nav visible), but no map renders. No retry logic. No toast notification.

### Style Config — Supabase Fails

**Trigger:** Supabase unreachable, anon key invalid, or `style_config` table missing/empty.

**Handler:** `loadStyleConfig()` `.catch()` block:
```javascript
.catch(function() {
    // Supabase unreachable — continue with defaults, no error thrown
});
```

The map continues with `DEFAULTS` camera values. No UI feedback. This is intentional — `style_config` is a convenience override, not a requirement.

### Route GeoJSON — Individual File Fails

**Trigger:** A single route file is missing, returns non-200, or contains malformed JSON.

**Handler:** Per-file `try/catch` in `loadRMMRoutes()`:
```javascript
try {
    var response = await fetch(url);
    if (!response.ok) {
        console.error('Failed to load route: ' + url + ' (' + response.status + ')');
        continue;  // skip this file, continue with next
    }
    var data = await response.json();
    ...
} catch (e) {
    console.error('Error loading route ' + url + ':', e);
}
```

Failed routes are skipped silently. The remaining routes still render. If all routes fail, `features.length === 0` triggers:
```javascript
console.warn('RMM: No routes loaded');
return;  // no layers added
```

No UI feedback for partial or complete route load failure.

### Marker Icons — SVG Load Fails

**Trigger:** SVG file missing or fetch error.

**Handler:** Each icon load has a `.catch()`:
```javascript
loadSVGAsMapIcon(icon.file, icon.mapId, icon.size)
    .catch(function() { console.warn('RMM: Failed to load icon', icon.mapId); })
```

A failed icon is silently skipped. The layer that references that `mapId` will render no icon for features that need it — the feature is still in the data, just invisible. No UI feedback.

### Email Overlay — Submit Fails

**Trigger:** Network error, validation failure, server error.

Three failure paths from `handleOverlaySubmit()`:

**1. Network error** (fetch throws):
```javascript
.catch(function() {
    errorEl.textContent = 'Network error. Try again.';
    submitBtn.disabled = false;
    submitBtn.textContent = 'Join the List';
});
```

**2. Server returns an error body**:
```javascript
} else {
    errorEl.textContent = data.error || 'Something went wrong. Try again.';
    submitBtn.disabled = false;
    submitBtn.textContent = 'Join the List';
}
```

**3. Duplicate email (409)** — treated as success from the user's perspective:
```javascript
} else if (data.error === 'Already subscribed.') {
    localStorage.setItem('rmm_subscribed', 'true');
    dismissOverlay();  // immediate, no success message shown
}
```

In all error cases: the inline error paragraph (`id="overlay-error"`) displays the message; the submit button is re-enabled; the form remains open for correction.

### Email Overlay — Client Validation Fails

**Trigger:** User submits with missing name, missing email, invalid email format, or unchecked consent.

```javascript
if (!name) { errorEl.textContent = 'Please enter your first name.'; return; }
if (!email) { errorEl.textContent = 'Please enter your email.'; return; }
if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { errorEl.textContent = 'Invalid email format.'; return; }
if (!consent) { errorEl.textContent = 'Please tick the box to continue.'; return; }
```

Errors display inline in `#overlay-error`. No fetch is made. The button is not disabled.

### Static Pages — No Error Handling

All pages other than `/map` and `/dashboard` are static HTML with no data fetching. They have no error states.

---

## 8. Data Flow Diagrams

### Map Initialisation

```
Browser                      Vercel Edge              Supabase
────────                     ────────────             ────────
GET /api/config ──────────►  api/config.js
                             reads env vars
                ◄────────── { token, styleUrl, ... }

new mapboxgl.Map(token, styleUrl)
map.on('load') fires

fetch SVGs ───────────────►  /public/icons/*.svg
           ◄───────────────  SVG text ×6

Mapbox fetches ────────────►  /public/data/peaks.geojson
               ◄────────────  GeoJSON FeatureCollection
Mapbox fetches ────────────►  /public/data/caves.geojson
               ◄────────────  GeoJSON FeatureCollection

fetch routes ──────────────►  /public/data/routes/*.geojson ×8
             ◄──────────────  GeoJSON FeatureCollection ×8

GET /rest/v1/style_config ─►                          style_config table
                          ◄─                          [{ key, value }, ...]

map.easeTo(overrides)
window.rmmMapReady = true
```

### Email Signup

```
Browser                    Vercel Serverless          Supabase
────────                   ─────────────────          ────────
User submits form
Client validates
POST /api/subscribe ─────►  api/subscribe.js
{ name, email, source }     Server validates
                            POST /rest/v1/subscribers ──►  subscribers table
                                                     ◄── 201 Created
                        ◄── { success: true }

localStorage.rmm_subscribed = 'true'
Overlay dismissed after 2s
```

### Duplicate Subscriber Path

```
Browser                    Vercel Serverless          Supabase
────────                   ─────────────────          ────────
POST /api/subscribe ─────►  api/subscribe.js
                            POST /rest/v1/subscribers ──►  UNIQUE constraint fires
                                                     ◄── 409 Conflict
                        ◄── 409 { error: 'Already subscribed.' }

Client detects exact string
localStorage.rmm_subscribed = 'true'
Overlay dismissed immediately (no success message)
```

---

## 9. What Pages Fetch Data

| Page / Route | Fetches data? | What |
|---|---|---|
| `/map` | Yes | Config, SVGs, GeoJSON, style_config |
| `/dashboard` | Yes | Same as `/map` (embedded map) |
| `/about` | No | Static HTML |
| `/intelligence` | No | Static HTML |
| `/intelligence/fitness` | Yes | Calls `/api/auth/session` (auth check) → `/api/python/calculate-rps` (RPS score) → `/api/auth/strava-activities` (sync trigger) |
| `/intelligence/routes` | Yes | Route Analyzer: drag-drop GPX → POST `/api/python/analyze` → renders grade result |
| `/intelligence/route-grading` | Yes | GPX upload → POST `/api/python/analyze` (public). Save → POST `/api/python/upload` (auth). History → GET `/api/python/upload?action=history` (auth). Toggles → POST `/api/python/upload` JSON action=toggle (admin). Merge → POST `/api/python/upload` JSON action=merge (auth) |
| `/intelligence/rps` | Yes | Calls `/api/auth/session` (auth check) → `/api/python/calculate-rps` (live score when Strava connected) |
| `/intelligence/readiness` | Yes | Calls `/api/auth/session` → `/api/python/race-readiness?route_id=X&athlete_id=Y` |
| `/leaderboards` | No | Static HTML |
| `/event` | No | Static HTML |
| `/shop` | No | Static HTML |
| `/product` | No | Static HTML |
| `/trails` | Yes | `GET /api/python/trails?action=browse` — lightweight trail metadata for card grid |
| `/trail/:slug` | Yes | `GET /api/python/trails?action=get-trail&slug=X` (trail + segments + POIs), `GET /api/auth/session?type=mapconfig` (mini-map token) |
| `/intelligence/trail-library` | Yes | Admin-gated. Multiple trail CRUD endpoints via `/api/python/trails` (see Trails & POIs API section) |
| `/intelligence/poi-manager` | Yes | Admin-gated. POI CRUD via `/api/python/pois` + map preview via `/api/auth/session?type=mapconfig` |
| `/privacy`, `/terms`, etc. | No | Static HTML |

### API Endpoints — Auth (added 2026-05-03)

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/auth/strava-login` | GET | Redirects to Strava OAuth consent screen |
| `/api/auth/strava-callback` | GET | Exchanges auth code for tokens, upserts athlete, sets session cookie |
| `/api/auth/session` | GET | Returns current athlete (public fields) or 401; auto-refreshes expired tokens |
| `/api/auth/logout` | GET | Invalidates session, clears cookie, redirects to /map |
| `/api/auth/strava-activities` | GET+POST | GET: fetches recent Strava activities. POST `{days: N}`: syncs activities into Supabase (fetches streams, converts GPX, stores with metrics) |

### API Endpoints — Python Engines (added 2026-04-25)

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/python/analyze` | POST | Public GPX upload + grade (no auth required, no Supabase writes) |
| `/api/python/upload` | GET+POST | **GET:** `?action=history&athlete_id=X` returns route analyses. **POST multipart:** GPX upload + process + anti-gaming + grading + duplicate detection. **POST JSON:** `action=toggle` (admin toggle show_on_map/include_in_readiness), `action=merge` (merge duplicate routes). Rewritten 2026-05-11 to 482 lines with multi-action routing. |
| `/api/python/calculate-rps` | POST | Calculate RPS for athlete, upsert rps_scores, insert rps_history. Early-returns `{rps:0}` if no activities (avoids env var crash). |
| `/api/python/race-readiness` | GET | Run 5-check assessment for athlete vs route |
| `/api/python/recalculate-decay` | POST | Daily decay recalculation for all/specific athletes |

### API Endpoints — Trails & POIs (added 2026-05-19)

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/python/trails?action=create` | POST (multipart) | GPX upload → grade → save as draft trail |
| `/api/python/trails?action=list-all` | GET | All trails (all statuses) for admin library |
| `/api/python/trails?action=browse` | GET | Lightweight trail list for public browse page (live trails only, seasonal filtering) |
| `/api/python/trails?action=get-trail&slug=X` | GET | Full trail data + segments + linked POIs for public detail page |
| `/api/python/trails?action=routes` | GET | Live route GeoJSON for map rendering (replaces static files) |
| `/api/python/trails?action=segments&trail_id=X` | GET | Per-km segments for segment editor |
| `/api/python/trails?action=update` | POST | Status toggle, rename, archive |
| `/api/python/trails?action=update-segment` | POST | Save segment edits (notes, tags, terrain) |
| `/api/python/trails?action=snip` | POST | Extract km range as new draft |
| `/api/python/trails?action=event-types` | GET | Event type dropdown options |
| `/api/python/trails?action=link-poi` | POST | Associate a POI with a trail at a km position |
| `/api/python/trails?action=unlink-poi` | POST | Remove a POI association from a trail |
| `/api/python/trails?action=trail-pois&trail_id=X` | GET | List POIs linked to a trail |
| `/api/python/pois?action=list` | GET | All POIs for admin library |
| `/api/python/pois?action=map-data` | GET | POI GeoJSON for map rendering |
| `/api/python/pois?action=create` | POST | Create new POI |
| `/api/python/pois?action=update` | POST | Edit existing POI |
| `/api/python/pois?action=delete` | POST | Delete POI |

**Note:** `/api/python/pois` routes to the same `trails.py` serverless function via Vercel rewrite (`/api/python/pois` → `/api/python/trails`). All trail and POI endpoints share a single Python function to stay within Vercel's 12-function Hobby plan limit.

**Status:** `/api/python/analyze` is LIVE and functional. The other Python endpoints are deployed and wired to frontend pages. They require 93 formula env vars in Vercel — 60 (route grading) are set, 33 (RPS/readiness) are prepared in `vercel-paste-ready.txt` but not yet added. The `calculate_rps` endpoint gracefully returns zero scores when no activities exist.
