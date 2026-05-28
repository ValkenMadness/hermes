---
title: website_architecture
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-27
updated_by: claude_cowork
tags: [codebase, website, architecture, tech-stack]
retrieval_priority: high
supersedes: ""
related: ["[[website_component_map]]", "[[website_key_files]]", "[[platform_architecture_and_tech_stack]]", "[[website_build_status_overview]]", "[[map_and_website_architecture]]", "[[map_system_overview]]", "[[website_build_status_issues]]", "[[website_data_flow]]", "[[website_deployment_and_devops]]", "[[website_styling_overview]]"]
---

# RMM Website Architecture

Run Mad Maps is a trail intelligence platform for the Cape Peninsula. Vanilla JavaScript, HTML, and CSS frontend. Serverless backend on Vercel. PostgreSQL data via Supabase. No React. No build pipeline. No npm dependencies.

---

## 1. Tech Stack

### Frontend
| Layer | Technology | Version / Source |
|---|---|---|
| Language | Vanilla JavaScript (ES6+) | — |
| Markup | HTML5 | — |
| Styling | CSS3 (custom properties, grid, flexbox) | — |
| Map Engine | Mapbox GL JS | v3.3.0 via CDN |
| Map Style | Custom Mapbox Studio style | `mapbox://styles/valkenmadness/cmnsvhzns002701qwc1xshumo` |
| Fonts | Space Mono | Google Fonts CDN |
| Icons | SVG only (custom t0–t4 system) | /public/icons/ |

### Backend
| Layer | Technology | Notes |
|---|---|---|
| Runtime | Node.js | Vercel managed |
| Functions | Vercel Serverless (CommonJS) | /api/ directory |
| HTTP | Native `fetch` API | No axios, no node-fetch |

### Data & Services
| Layer | Technology | Notes |
|---|---|---|
| Database | Supabase (PostgreSQL) | REST API (no Supabase JS SDK) |
| Static Geographic Data | GeoJSON files | /public/data/ |
| Hosting & CDN | Vercel | Auto-deploy on push to main |

### What is explicitly excluded
- React (prohibited by CLAUDE.md)
- Any npm runtime dependency (`package.json` has no `dependencies` or `devDependencies`)
- Build tools (webpack, vite, esbuild)
- TypeScript
- Any CSS framework

---

## 2. Project Structure

```
THE OFFICIAL BUILD/
│
├── index.html                        # Root entry: immediate meta-refresh → /map
├── CLAUDE.md                         # Architecture rules (authoritative — AI must read this)
├── vercel.json                       # URL rewrites + security headers
├── package.json                      # Metadata only; no dependencies
├── .env                              # Local secrets (not committed)
├── .env.example                      # Secret names template (committed)
├── .gitignore                        # Excludes .env, .env.local, node_modules, .vercel
│
├── api/                              # Vercel serverless functions (12-function limit on Hobby plan)
│   ├── subscribe.js                  # POST — validates email, writes to Supabase subscribers table
│   ├── auth/                         # Auth endpoints (added 2026-05-03, expanded 2026-05-08)
│   │   ├── account.js                # POST — consolidated signup/signin/admin-grant (?action= routing)
│   │   ├── session.js                # GET — returns current user or athlete; also serves map config (?type=mapconfig)
│   │   ├── strava-login.js           # GET — redirects to Strava consent screen
│   │   ├── strava-callback.js        # GET — exchanges code for tokens, links to user or creates legacy session
│   │   ├── strava-activities.js      # GET+POST — GET fetches recent activities, POST syncs to Supabase
│   │   └── logout.js                 # GET — invalidates session in BOTH users + athletes tables, clears cookie, redirects to /map (dual-table logout fixed 2026-05-12)
│   └── python/                       # Python serverless — formula engines (added 2026-04-25)
│       ├── _config.py                # Config class — reads all 93+ formula env vars via _LazyDescriptor (DDS vars added 2026-05-19)
│       ├── _supabase.py              # Minimal Supabase REST client (urllib.request, no SDK)
│       ├── _gps_processor.py         # GPS Stream Processor — direct port + descent detection (extended 2026-05-19)
│       ├── _route_grader.py          # Route Grading V3 — direct port
│       ├── _descent_grader.py        # Descent Difficulty Score engine — DDS calculation, switchback detection, composite grade builder (added 2026-05-19)
│       ├── _rps_engine.py            # RPS Engine — direct port
│       ├── _race_readiness.py        # Race Readiness Engine — direct port
│       ├── _anti_gaming.py           # Anti-Gaming Validator (F1–F10) — direct port
│       ├── _dem_lookup.py            # DEM elevation — graceful fallback (no SRTM on Vercel)
│       ├── pyproject.toml            # Minimal project file for Vercel uv build system
│       ├── upload.py                 # GET+POST /api/python/upload — multi-action: GPX upload+grade (authed+public), history, toggle, merge (absorbed analyze.py 2026-05-19)
│       ├── trails.py                 # GET+POST /api/python/trails — trail CRUD, segment CRUD, snip, event types, POI CRUD + list (added 2026-05-19, POI CRUD added 2026-05-20)
│       ├── calculate_rps.py          # POST /api/python/calculate-rps — RPS scoring (early-return if 0 activities)
│       ├── race_readiness_check.py   # GET /api/python/race-readiness — 5-check assessment
│       └── recalculate_decay.py      # POST /api/python/recalculate-decay — daily decay cron
│       NOTE: Files prefixed with _ are helper modules, NOT serverless functions.
│             Vercel ignores them. This keeps the function count at 12 (Hobby plan limit).
│       NOTE: analyze.py was deleted (absorbed into upload.py). Vercel rewrite
│             routes /api/python/analyze → upload.py for backward compat.
│
├── pages/                            # HTML pages (all routed via vercel.json rewrites)
│   ├── map.html                      # Primary product: interactive 3D map
│   ├── about.html                    # Platform story, systems explanation, founder
│   ├── signup.html                   # Athlete registration (email/password, race number reveal)
│   ├── signin.html                   # Login form (supports ?return_to= redirect)
│   ├── profile.html                  # Athlete profile (race card, Strava connection, admin panel)
│   ├── dashboard.html                # User hub (auth-aware, shows Account Required when logged out)
│   ├── intelligence.html             # Tool hub landing
│   ├── intelligence-fitness.html     # RPS (Running Performance Score) detail
│   ├── intelligence-routes.html      # Route grading detail + grade table (explainer)
│   ├── intelligence-route-grading.html # Route Grading Tool — GPX upload, save, admin toggles, history (added 2026-05-11)
│   ├── intelligence-rps.html         # RPS deep-dive with live score display (added 2026-05-11)
│   ├── intelligence-readiness.html   # Race Readiness 5-check system detail (explainer)
│   ├── intelligence-race-readiness.html # Race Readiness Tool — route selector, verdict, 5-check cards, PI detail (added 2026-05-12)
│   ├── intelligence-trail-library.html # Trail Library — admin GPX upload, grading, segment editor, library table (added 2026-05-19)
│   ├── intelligence-poi-manager.html  # POI Manager — admin POI creation, editing, status toggles, icon preview (added 2026-05-20)
│   ├── leaderboards.html             # GPS-verified leaderboards (coming soon)
│   ├── event.html                    # Single event detail page
│   ├── product.html                  # Single product detail (Cape Peninsula map)
│   ├── shop.html                     # Shop grid
│   ├── privacy.html                  # Privacy policy
│   ├── terms.html                    # Terms of service
│   ├── cookies.html                  # Cookie policy
│   ├── acceptable-use.html           # Acceptable use policy
│   └── legal.html                    # Legal index page
│
├── scripts/                          # JavaScript modules (no imports between modules)
│   ├── auth.js                       # Client-side auth module — RMMAuth.check(), .login(), .signup(), .connectStrava(), .logout(), .isAdmin(), .isStravaConnected(), .updateUI()
│   ├── components.js                 # Shared nav + footer; auth-aware nav (Sign In/Profile toggle, admin link injection)
│   ├── map.js                        # Full Mapbox GL JS map engine (~600 lines)
│   ├── route-analyzer.js             # Route Analyzer UI — drag-drop GPX upload, result rendering
│   ├── trail-library.js              # Trail Library admin UI — GPX upload, grade display, library table, segment editor modal, rename, map preview (added 2026-05-19)
│   └── poi-manager.js               # POI Manager admin UI — create/edit form, POI table, status toggles, icon preview, edit modal (added 2026-05-20)
│
├── styles/                           # CSS files (no preprocessors)
│   ├── components.css                # CSS variables, nav, footer, shared section shells
│   ├── main.css                      # Global base styles + landing page
│   ├── map.css                       # Map container, Mapbox control overrides, popups
│   └── pages.css                     # Page-specific overrides (about, dashboard, intel, etc.)
│
└── public/                           # Static assets (served as-is by Vercel)
    ├── data/
    │   ├── peaks.geojson             # 65 Cape Peninsula peaks (22 KB; geographic truth)
    │   └── caves.geojson             # Cave POIs (14 KB; geographic truth)
    │   NOTE: routes/ directory REMOVED (2026-05-19). All route data now served
    │         from Supabase via /api/python/trails?action=list. See Trail Ecosystem.
    ├── icons/                        # SVG markers, t0–t4 tier system
    │   ├── peaks/                    # t1-peak-generic, t2-peak-generic, t3-peak-maclears-beacon, t4-peak-maclears-beacon
    │   ├── caves/                    # t1-cave-generic, t2-cave-generic, t3-cave-boomslang-cave, t4-cave-boomslang-cave
    │   ├── events/                   # (empty — future)
    │   ├── pois/                     # 28 POI icons: 14 categories × T1 (24px) + T2 (32px) (added 2026-05-20)
    │   └── zones/                    # (empty — future)
    ├── images/
    │   ├── logo.svg
    │   └── favicon.png
    ├── animations/                   # Sprite sheets (future)
    └── overlays/                     # GPS-pinned illustrations (future)
```

---

## 3. Build and Deployment

### Build Process
There is no build step. Vercel serves static files directly. The only "compilation" is Vercel bundling the two serverless functions in `/api/`.

### Deployment Pipeline
```
VS Code → git commit → git push origin main → Vercel auto-deploy → runmadmaps.com
```

All work pushes directly to `main`. Admin-gated pages are safe to deploy incomplete — the public never sees them. Feature branches optional for risky changes to public-facing pages.

### URL Routing
All clean URLs are handled by rewrites in `vercel.json`. There is no client-side router.

| Clean URL | Resolved File |
|---|---|
| `/` | `index.html` (meta-refresh → `/map`) |
| `/map` | `pages/map.html` |
| `/about` | `pages/about.html` |
| `/signup` | `pages/signup.html` |
| `/signin` | `pages/signin.html` |
| `/profile` | `pages/profile.html` |
| `/dashboard` | `pages/dashboard.html` |
| `/intelligence` | `pages/intelligence.html` |
| `/intelligence/fitness` | `pages/intelligence-fitness.html` |
| `/intelligence/routes` | `pages/intelligence-routes.html` |
| `/intelligence/route-grading` | `pages/intelligence-route-grading.html` |
| `/intelligence/rps` | `pages/intelligence-rps.html` |
| `/intelligence/readiness` | `pages/intelligence-readiness.html` |
| `/intelligence/race-readiness` | `pages/intelligence-race-readiness.html` |
| `/leaderboards` | `pages/leaderboards.html` |
| `/event` | `pages/event.html` |
| `/shop` | `pages/shop.html` |
| `/product` | `pages/product.html` |
| `/privacy` | `pages/privacy.html` |
| `/terms` | `pages/terms.html` |
| `/cookies` | `pages/cookies.html` |
| `/acceptable-use` | `pages/acceptable-use.html` |
| `/legal` | `pages/legal.html` |
| `/intelligence/trail-library` | `pages/intelligence-trail-library.html` |
| `/intelligence/poi-manager` | `pages/intelligence-poi-manager.html` |
| `/api/config` | `api/auth/session.js?type=mapconfig` (consolidated) |
| `/api/subscribe` | `api/subscribe.js` |
| `/api/python/analyze` | `api/python/upload.py` (rewrite — analyze.py deleted) |
| `/api/python/upload` | `api/python/upload.py` |
| `/api/python/trails` | `api/python/trails.py` |
| `/api/python/pois` | `api/python/trails.py` (rewrite — POI actions in same function) |

### Security Headers (set globally in vercel.json)
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`

### Environment Variables

These names are required. Values are never committed. Set in Vercel dashboard for production; set in `.env` for local development.

| Variable | Used By | Purpose |
|---|---|---|
| `MAPBOX_PUBLIC_TOKEN` | `api/auth/session.js` (mapconfig) | Delivered to client for GL JS init |
| `MAPBOX_STYLE_URL` | `api/auth/session.js` (mapconfig) | Custom Mapbox Studio style URL |
| `TRAILS_TILESET_ID` | `api/auth/session.js` (mapconfig) | Optional custom trails tileset |
| `CONTOURS_TILESET_ID` | `api/auth/session.js` (mapconfig) | Optional contours tileset |
| `SUPABASE_URL` | `api/auth/*.js`, `api/subscribe.js`, `scripts/map.js` | Supabase project URL |
| `SUPABASE_ANON_KEY` | `scripts/map.js` | Read-only client key (safe to expose) |
| `SUPABASE_SERVICE_ROLE_KEY` | `api/auth/*.js`, `api/subscribe.js` | Server-only write key |

| `RMM_PLATFORM_VERSION` | `api/auth/account.js`, `api/auth/session.js` | Platform version string (e.g. `1.0`). Stamped on login/signup; checked on every session. Bumping this value invalidates all existing sessions. Added 2026-05-12. |
| `strava_oauth_client_id` | `api/auth/strava-login.js`, `api/auth/strava-callback.js`, `api/auth/session.js` | Strava app client ID (163342) |
| `strava_oauth_client_secret` | `api/auth/strava-callback.js`, `api/auth/session.js` | Strava app secret (server-only) |

| Formula env vars (93 total) | `api/python/_config.py` | All formula thresholds, weights, ceilings, and matrix — see `vercel-paste-ready.txt` for full list. Groups: Distance Bands, ED Bands, Base Class Matrix, Grade Modifiers, TDS, Effort Descriptor, Climb Detection, Pillar 3, TBS Weights, RCS Weights, Gradient Analysis, Moving Time, DEM, Pace Consistency, RPS Weights, RPS Ceilings (road/trail/hike), Decay, Levels, PI Expected Paces, Race Readiness Thresholds, Anti-Gaming Thresholds, Pace Consistency Gradient, TDS Bonus |
| DDS env vars (16 total) | `api/python/_config.py` | Descent Difficulty Score weights, grade thresholds, normalisation ceilings, and detection thresholds — see `vercel-dds-env-vars.txt`. Groups: DDS_WEIGHT_* (6 component weights), DDS_GRADE_*_MAX (5 grade boundaries), DDS_NORM_* (3 normalisation ceilings), DESCENT_MIN_LOSS_M, DESCENT_END_CLIMB_M. All provisional — subject to calibration. Added 2026-05-19. |

**Important note on key exposure:** `SUPABASE_URL` and `SUPABASE_ANON_KEY` are hardcoded directly in `scripts/map.js` because the anon key is read-only by design and Supabase's RLS (Row Level Security) governs access. This is the Supabase-recommended client pattern. The service role key is strictly server-side only.

---

## 4. Database / Data Layer

### Supabase (PostgreSQL)

**Project URL:** `https://lpzppqveekozdvqdduqg.supabase.co`

Access method: raw Supabase REST API (`fetch` to `/rest/v1/<table>`). The Supabase JS SDK is not used.

#### Known Tables

**`subscribers`**
Email capture table. Written to by `/api/subscribe.js`.

| Column | Type | Notes |
|---|---|---|
| `email` | text | Unique constraint — duplicate inserts return 409 |
| `first_name` | text | From `name` field in form submission |
| `consent_given` | boolean | Always `true` (form requires checkbox) |
| `source` | text | Origin of signup (e.g. `landing_page`); sanitized to `[a-z0-9\-_]`, max 64 chars |
| `created_at` | timestamp | Supabase default |

**`style_config`**
Map configuration key-value store. Read by `scripts/map.js` at map init to override camera defaults.

| Column | Type | Notes |
|---|---|---|
| `key` | text | Config key name |
| `value` | text / numeric | Config value |

Keys used by map.js: `center_lng`, `center_lat`, `zoom`, `pitch`, `bearing`, `terrain_exaggeration`. Map falls back to hardcoded `DEFAULTS` if Supabase is unreachable.

**`activities`** (added 2026-05-05)
Synced Strava activities for scoring. Written by `api/auth/strava-activities.js`, read by `api/python/calculate_rps.py` and `api/python/race_readiness_check.py`.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key (generated) |
| `athlete_id` | text | String of Strava athlete ID |
| `source` | text | `strava` or `gpx_upload` |
| `activity_type` | text | `road`, `trail`, or `hike` |
| `purpose` | text | `training` or `race` |
| `date` | date | Activity date |
| `total_distance_km` | numeric | Total distance |
| `total_elevation_gain` | numeric | Elevation gain in metres |
| `rmm_moving_time_seconds` | numeric | Moving time |
| `elevation_density` | numeric | Gain per km |
| `rmm_avg_pace_sec_per_km` | numeric | Average pace |
| `rmm_avg_speed_kmh` | numeric | Average speed |
| `terrain_difficulty_score` | numeric | TDS 1–10 |
| `pace_consistency_score` | numeric | 0–1 score |
| `pace_consistency_tier` | text | Tier label |
| `km_splits` | jsonb | Per-km split data |
| `include_in_scoring` | boolean | Whether to include in RPS |
| `raw_data` | jsonb | Full Strava activity JSON |
| `raw_gpx` | text | Generated GPX string |
| `flags` | jsonb | Anti-gaming flag results |
| `flag_severity` | text | `none`, `warning`, `critical` |
| `show_on_map` | boolean | Admin toggle — show route on map (added 2026-05-11, default false) |
| `include_in_readiness` | boolean | Admin toggle — include in race readiness scoring (added 2026-05-11, default false) |
| `merged_from` | jsonb | Array of activity IDs merged into this route (added 2026-05-11, default null) |
| `created_at` | timestamptz | Insert timestamp |
| `updated_at` | timestamptz | Last update |

RLS enabled. Service role key for all access.

**`rps_scores`** (added 2026-05-05)
Current RPS scores per athlete per activity type. Upserted by `api/python/calculate_rps.py`.

| Column | Type | Notes |
|---|---|---|
| `athlete_id` | text | FK to athletes (by strava_id string) |
| `activity_type` | text | `road`, `trail`, `hike`, or `overall` |
| `rps` | numeric | Current RPS value (0–100) |
| `level_name` | text | Foundation/Active/Athlete/Competitor/Elite |
| `level` | jsonb | Full level object with floor/ceiling/position |
| `activity_count` | integer | Activities in scoring window |
| `reference_date` | timestamptz | When calculated |
| `updated_at` | timestamptz | Last upsert |
| `rps_data` | jsonb | Full sanitized breakdown |

Unique constraint on `(athlete_id, activity_type)`.

**`rps_history`** (added 2026-05-05)
Historical RPS snapshots for trend graphs. Inserted by `api/python/calculate_rps.py`.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `athlete_id` | text | FK to athletes |
| `activity_type` | text | `road`, `trail`, `hike`, or `overall` |
| `rps` | numeric | Score at that point in time |
| `level_name` | text | Level at that point |
| `reference_date` | timestamptz | When calculated |
| `created_at` | timestamptz | Insert timestamp |

**`route_analyses`** (added 2026-05-05)
Stored route grades from the grading engine. Written by `api/python/upload.py`.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `activity_id` | uuid | FK to activities |
| `grade` | text | A–F |
| `tds` | numeric | 1–10 |
| `elevation_density` | numeric | m/km |
| `effort_descriptor` | text | Flat/Undulating/Hilly/etc |
| `analysis_data` | jsonb | Full grading result |
| `created_at` | timestamptz | Insert timestamp |

**`users`** (added 2026-05-08)
Primary identity table for email/password auth. All new signups go here.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key (gen_random_uuid) |
| `email` | text | UNIQUE NOT NULL |
| `password_hash` | text | `salt:hash` format (scryptSync) |
| `first_name` | text | NOT NULL |
| `last_name` | text | NOT NULL |
| `gender` | text | `male`, `female`, `prefer_not_to_say` (default) |
| `age` | integer | Optional (13–120) |
| `race_number` | text | UNIQUE NOT NULL — format `RMM-XXXXXX` |
| `role` | text | `athlete` (default) or `admin` |
| `strava_connected` | boolean | Default false — set true when Strava linked |
| `strava_athlete_id` | bigint | Linked Strava athlete ID (from callback) |
| `session_token` | text | Random UUID for httpOnly cookie |
| `session_version` | text | Platform version at login (e.g. `1.0`). Compared against `RMM_PLATFORM_VERSION` env var on every session check — mismatch forces re-login. Added 2026-05-12. |
| `created_at` | timestamptz | Account creation |
| `updated_at` | timestamptz | Last update |
| `last_login` | timestamptz | Last login |

RLS enabled. Indexes on `session_token`, `email`, `race_number`, `strava_athlete_id`. No public access — all reads/writes via service role key.

**`athletes`** (added 2026-05-03)
Strava OAuth athlete records. Written by `api/auth/strava-callback.js`, read by `api/auth/session.js`.

| Column | Type | Notes |
|---|---|---|
| `id` | bigserial | Primary key |
| `strava_id` | bigint | UNIQUE — Strava athlete ID |
| `first_name` | text | From Strava profile |
| `last_name` | text | From Strava profile |
| `profile_pic` | text | Strava profile image URL |
| `city` | text | From Strava profile |
| `country` | text | From Strava profile |
| `sex` | text | From Strava profile |
| `strava_access_token` | text | OAuth access token (server-only, never exposed to client) |
| `strava_refresh_token` | text | OAuth refresh token (server-only) |
| `strava_token_expires_at` | bigint | Unix timestamp — auto-refreshed by session.js |
| `strava_scope` | text | Granted OAuth scopes |
| `session_token` | text | Random UUID for httpOnly cookie session |
| `created_at` | timestamptz | Account creation |
| `updated_at` | timestamptz | Last token/profile update |
| `last_login` | timestamptz | Last OAuth login |
| `rps_current` | numeric | Reserved for future RPS score |
| `athlete_level` | text | Reserved for future level band |
| `total_activities` | integer | Reserved for future activity count |

RLS enabled. No public access policies — all reads/writes via service role key in serverless functions. Anon key cannot access this table.

**`trails`** (added 2026-05-19)
Primary table for all curated trail content. Stores geometry, grades, metadata, and publish state. Written by `api/python/trails.py`, read by map via `?action=list`.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `name` | text | Trail name |
| `slug` | text | UNIQUE — URL-safe slug (auto-generated, updated on rename) |
| `description` | text | Optional |
| `event_type` | text | `trail`, `time_trial`, `hill_climb`, `hill_bomb` |
| `status` | text | `draft`, `live`, `archived` — only `live` trails appear on public map |
| `geometry` | geometry(LineString, 4326) | PostGIS geometry (populated but not yet used for queries) |
| `coordinates_json` | jsonb | `[[lng, lat, ele], ...]` — primary source for GeoJSON API responses |
| `grade` | text | A–F |
| `grade_display` | text | e.g. "C3" |
| `tds` | numeric | Terrain Difficulty Score 1–10 |
| `effort_descriptor` | text | Flat/Undulating/Hilly/etc. |
| `composite_grade` | jsonb | `{"overall": "C3", "climbs": [...], "descents": [...], "road_percentage": 0, "trail_percentage": 100}` |
| `total_distance_km` | numeric | Total distance |
| `total_elevation_gain` | numeric | Metres |
| `total_elevation_loss` | numeric | Metres |
| `elevation_density` | numeric | m/km |
| `min_elevation` | numeric | Metres |
| `max_elevation` | numeric | Metres |
| `road_percentage` | numeric | 0–100 |
| `trail_percentage` | numeric | 0–100 |
| `climb_count` | integer | Number of detected climbs |
| `descent_count` | integer | Number of detected descents |
| `elevation_profile` | jsonb | `[{distance_km, elevation}, ...]` for SVG rendering |
| `km_splits` | jsonb | Per-km split data from GPS processor |
| `analysis_data` | jsonb | Full grading result (internal) |
| `raw_gpx` | text | Original GPX content |
| `source_activity_id` | uuid | FK to activities (optional) |
| `created_by` | uuid | FK to users |
| `seasonal_start` | date | null = always available |
| `seasonal_end` | date | null = always available |
| `created_at` | timestamptz | Insert timestamp |
| `updated_at` | timestamptz | Last update |

Indexes on `status`, `event_type`, `geometry` (GIST). RLS enabled.

**`trail_segments`** (added 2026-05-19)
Per-km segment breakdown with auto-computed metrics and admin-set tags. Written by `trails.py` on trail creation (auto-generated) and segment update.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `trail_id` | uuid | FK to trails (CASCADE delete) |
| `km_start` | numeric | Start km position |
| `km_end` | numeric | End km position |
| `sort_order` | integer | Display order |
| `segment_type` | text | `climb`, `descent`, `flat`, `rolling` |
| `terrain_type` | text | `trail` or `road` (admin-set) |
| `surface_type` | text | `rock`, `sand`, `gravel`, `dirt`, `paved`, null |
| `track_width` | text | `single_track`, `jeep_track`, `road`, null |
| `exposure` | text | `open`, `partial`, `covered`, null |
| `gradient_avg` | numeric | Average gradient |
| `gradient_max` | numeric | Max gradient |
| `gradient_min` | numeric | Min gradient |
| `elevation_gain` | numeric | Metres |
| `elevation_loss` | numeric | Metres |
| `distance_km` | numeric | Segment distance |
| `switchback_count` | integer | Sharp turns detected |
| `gradient_variability` | numeric | Std dev of gradient |
| `grade` | text | Segment-specific A–F |
| `tds` | numeric | Segment TDS |
| `notes` | text | Free-text admin notes |
| `coord_start_idx` | integer | Index into trail coordinate array |
| `coord_end_idx` | integer | Index into trail coordinate array |
| `created_at` | timestamptz | Insert timestamp |
| `updated_at` | timestamptz | Last update |

Index on `trail_id`.

**`trail_pois`** (added 2026-05-19, POI Manager UI added 2026-05-20)
Standalone map POIs — independent of trails. Admin creates/edits via `/intelligence/poi-manager`. Live POIs render on the main map via `/api/python/pois` endpoint.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `name` | text | NOT NULL |
| `category` | text | waterfall, stream_crossing, viewpoint, etc. |
| `icon_key` | text | Maps to icon library |
| `description` | text | Optional |
| `latitude` | numeric | NOT NULL |
| `longitude` | numeric | NOT NULL |
| `location` | geometry(Point, 4326) | PostGIS point |
| `elevation` | numeric | Optional |
| `status` | text | `draft` or `live` |
| `metadata` | jsonb | Extensible attributes |
| `created_by` | uuid | FK to users |
| `created_at` | timestamptz | Insert timestamp |
| `updated_at` | timestamptz | Last update |

Indexes on `status`, `category`, `location` (GIST).

**`trail_poi_links`** (added 2026-05-19)
Many-to-many association between trails and POIs. Table exists but is empty (Phase 5).

| Column | Type | Notes |
|---|---|---|
| `trail_id` | uuid | FK to trails (CASCADE) |
| `poi_id` | uuid | FK to trail_pois (CASCADE) |
| `km_position` | numeric | Where the POI is encountered on this trail |

Composite PK on `(trail_id, poi_id)`.

**`event_types`** (added 2026-05-19)
Extensible event type registry. Seeded with 4 defaults: trail, time_trial, hill_climb, hill_bomb.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `key` | text | UNIQUE — `trail`, `time_trial`, `hill_climb`, `hill_bomb` |
| `display_name` | text | Human-readable name |
| `description` | text | Optional |
| `grading_profile` | text | `standard`, `climb_focus`, `descent_focus`, `timed` |
| `is_active` | boolean | Default true |
| `sort_order` | integer | Display order |
| `created_at` | timestamptz | Insert timestamp |

#### Static Data (GeoJSON — not in Supabase)

Geographic truth for peaks and caves lives in version-controlled GeoJSON files. Trail/route data has migrated to the database (2026-05-19).

- `/public/data/peaks.geojson` — 65 named peaks; point features with `name`, `elevation` properties
- `/public/data/caves.geojson` — cave POIs; point features with `name` property

**Rule:** GeoJSON = geographic truth for peaks/caves. Supabase = geographic + operational truth for trails/POIs. The `trails` table with PostGIS geometry is now the source of truth for all route data.

---

## 5. Authentication

**Dual auth system (2026-05-08).** Email/password signup is the primary auth path. Strava OAuth remains as a secondary connection (not a login method).

### Email/Password Auth (Primary — added 2026-05-08)

New `users` table in Supabase is the primary identity store. Endpoints consolidated into `api/auth/account.js` for Vercel Hobby plan (12-function limit):

- `POST /api/auth/account?action=signup` — creates account, hashes password (Node.js `crypto.scryptSync`, no npm deps), generates unique race number (RMM-XXXXXX), sets httpOnly session cookie
- `POST /api/auth/account?action=signin` — verifies password, creates session, sets cookie
- `POST /api/auth/account?action=admin-grant` — admin-only, promotes another user to admin by email

**Race Numbers:** Format `RMM-XXXXXX` (100000–999999). Random generation with collision check loop (up to 10 attempts against Supabase). Assigned at signup, unique per athlete.

**Password Hashing:** `crypto.scryptSync` with 16-byte random salt. Stored as `salt:hash` in `password_hash` column. No npm dependencies.

**Session Management:** Same `rmm_session` httpOnly cookie pattern as Strava OAuth. Cookie duration controlled by "Remember me" checkbox on sign-in: checked = 30-day `Max-Age`; unchecked = session cookie (cleared when browser closes). Signup always sets 30-day cookie. Secure flag in production. SameSite=Lax.

**Platform Version Enforcement (added 2026-05-12):** `RMM_PLATFORM_VERSION` env var (e.g. `1.0`) is stamped into `session_version` column on users table at login/signup. On every session check (`/api/auth/session`), if the stored `session_version` doesn't match the current env var, the session is invalidated and the user must sign in again. This forces re-authentication when the platform updates (e.g. new terms, breaking changes). Bumping the env var in Vercel immediately invalidates all existing sessions.

**Admin System:** `role` column in users table. Valken (`valkenrunningmad@gmail.com`) auto-granted admin on signup. Admin can grant admin to others via the profile page. Admin flag synced to `localStorage.rmm_admin` for nav gating (convenience only — all real access control is server-side).

### Strava OAuth (Secondary — Connection, not Login)

**Strava OAuth is LIVE (2026-05-03).** Endpoints in `api/auth/`: `strava-login.js` (redirect to Strava consent), `strava-callback.js` (exchange code → tokens → Supabase upsert → session cookie OR link to existing user), `session.js` (check auth + auto-refresh tokens + map config), `logout.js` (invalidate + clear).

**Dual-mode Strava callback (2026-05-08):** If user is logged in via `users` table when connecting Strava, the callback links Strava to their user account (`strava_connected=true`, `strava_athlete_id`). If no user session exists, falls back to legacy athlete-only flow.

Client-side module `scripts/auth.js` exposes `window.RMMAuth` with `.check()`, `.login()`, `.signup()`, `.connectStrava()`, `.logout()`, `.onReady()`, `.updateUI()`, `.isAdmin()`, `.isStravaConnected()`, `.getAuthSource()`. Handles both `data.user` (new system) and `data.athlete` (legacy) responses, normalising legacy data into a unified shape.

Strava app Client ID: 163342. Scopes: `read,activity:read`. Session uses httpOnly+Secure+SameSite=Lax cookie (`rmm_session`). Athletes table in Supabase stores tokens with RLS enabled. Garmin OAuth not yet started.

### Three-State Page Gating (2026-05-08)

Intelligence pages and dashboard now show three states:
1. **Logged out:** "Sign Up to View" CTA with link to `/signup`
2. **Logged in, no Strava:** "Connect Strava" CTA using `RMMAuth.connectStrava()`
3. **Logged in + Strava connected:** Live data display

### New Pages

- `/signup` → `pages/signup.html` — Registration form (first name, last name, email, gender, age, password). On success shows race number reveal card.
- `/signin` → `pages/signin.html` — Email + password form. Supports `?return_to=` redirect. **Updated 2026-05-12:** "Remember me for 30 days" checkbox (custom-styled). Session detection via `/api/auth/session` API call (not cookie check — cookie is HttpOnly). Auto-redirects to dashboard/return_to if already logged in.
- `/profile` → `pages/profile.html` — Race number card, account details, Strava connection panel, admin controls (admin-only), sign out.

### Nav Auth Awareness (2026-05-08, fixed 2026-05-12)

Nav dynamically shows "Sign In" link for logged-out users and "Profile" link for logged-in users. Admin-only pages (Shop, Intelligence, Leaderboards, Dashboard) injected into nav dynamically for admin users via `addAdminNavLinks()` in `components.js`.

**Fix (2026-05-12):** Previously, the nav only knew auth state on pages that loaded `auth.js` (7 pages: dashboard, profile, intelligence pages). All other pages (about, shop, leaderboards, legal, etc.) defaulted to showing "Sign In" even when logged in. Fixed by making `components.js` do its own lightweight `/api/auth/session` fetch when `auth.js` isn't present, via the `applyNavAuthState()` helper. The nav now correctly shows "Profile" on every page when logged in.

---

## 6. External Services

### Mapbox
- **What:** Mapbox GL JS map engine + custom Mapbox Studio style
- **How:** Token fetched from `/api/config` at runtime; never in source code
- **Style:** Custom Studio style with 3D terrain (DEM source), hillshade, fog enabled
- **GL JS version:** 3.3.0 loaded via CDN (`https://api.mapbox.com/mapbox-gl-js/v3.3.0/`)
- **Terrain:** Mapbox DEM raster source with `exaggeration: 1.5` (configurable via `style_config`)
- **Icon loading:** SVGs are fetched, rasterised to canvas, and registered with `map.addImage()` — no native SVG layer support used

### Supabase
- **What:** Hosted PostgreSQL; used for email capture and map config
- **How:** Raw REST API (`fetch`), no SDK
- **Client access:** Anon key in `map.js` for reading `style_config`
- **Server access:** Service role key in `api/subscribe.js` for writing `subscribers`

### Vercel
- **What:** Static hosting + serverless function runtime
- **How:** Auto-deploy from GitHub `main` branch; preview deploys on all branches
- **Functions:** Node.js CommonJS (`module.exports = function handler(req, res)`)
- **CORS:** `/api/config` restricts origins to `https://runmadmaps.com` and `http://localhost:3000`

### Google Fonts
- **What:** Space Mono typeface
- **How:** `<link>` tag in HTML head, loaded via CDN

### No other external services are currently integrated.
Stripe, analytics, Garmin OAuth, and a dedicated admin interface are referenced in specs/pages but have no integration code. Strava OAuth is live (2026-05-03). Email/password auth is live (2026-05-08).

### Python Engine Runtime (added 2026-04-25, extended 2026-05-19)
- **What:** All four formula engines (GPS Stream Processor, Route Grading V3, RPS, Race Readiness) + Anti-Gaming Validator + Descent Grader + Trail CRUD
- **How:** Vercel Python serverless functions in `api/python/`. Pure Python stdlib — no pip dependencies.
- **Data:** Reads/writes via Supabase REST API using `urllib.request`. Service role key for writes.
- **Config:** All formula values read from `os.environ` (Vercel env vars). Same var names as Formula Lab `.env`.
- **DEM:** Graceful fallback to GPS altitude — no SRTM tiles on Vercel. `dem_corrected: false` recorded.
- **Config refactor:** `_config.py` uses `_LazyDescriptor` pattern for deferred env var loading — prevents import crashes when only grading vars are set (not RPS/readiness/anti-gaming vars).
- **Trail Ecosystem (added 2026-05-19):** `trails.py` handles all trail CRUD (create from GPX, update, archive, list), segment CRUD (auto-generate, update tags, notes), snipping (extract coordinate subset as new trail), and event type listing. `_descent_grader.py` computes Descent Difficulty Scores. `_gps_processor.py` extended with `_detect_descents()`. 16 DDS env vars set in Vercel. Admin auth via `rmm_session` cookie → `users.session_token` lookup.
- **Status:** GPS Stream Processor + Route Grading V3 + Descent Grader are **LIVE**. Public Route Analyzer at `/api/python/analyze` (rewritten to upload.py). Admin Trail Library at `/api/python/trails`. 60 route grading + 16 DDS env vars set in Vercel. RPS/Readiness/Anti-Gaming endpoints deployed and wired to frontend pages — but the remaining 33 RPS formula env vars must still be added to Vercel (prepared in `vercel-paste-ready.txt`). The `calculate_rps.py` endpoint has an early-return for zero activities that avoids crashing on missing env vars.

---

## 7. Key Architectural Rules (from CLAUDE.md — LOCKED)

These rules govern all edits. Violations require explicit sign-off.

1. **No React.** The live site is vanilla JS. The Formula Lab (local-only, separate) uses React.
2. **3D terrain from Stage 1.** Never retrofitted — it is a core visual identity element.
3. **No hardcoded styling in JavaScript.** Styling goes in CSS, Mapbox expressions, or `style_config`.
4. **GeoJSON = geographic truth. Supabase = operational truth.** Never swap these roles.
5. **All state that changes without a code deploy lives in Supabase.**
6. **Map is embeddable.** Full-page and dashboard-panel are config states; one codebase.
7. **Map never imports code from other modules** (Modular Isolation Principle).
8. **All cross-module communication** goes through Supabase or defined event callbacks.

---

## 8. Map Engine Detail (`scripts/map.js`)

The map is the primary product. Key implementation details for AI editors:

**Initialisation sequence:**
1. Fetch config from `/api/config` (token + style URL)
2. Initialise `mapboxgl.Map` with 3D terrain, fog, custom controls
3. On `style.load`: load all SVG icons via canvas rasterisation, then add layers
4. Fetch `style_config` from Supabase to override camera defaults (non-blocking)
5. Load all 8 route GeoJSON files in parallel; merge into single `rmm-routes` source

**Icon loading:** SVGs are fetched as blobs, drawn to an off-screen canvas, then registered with `map.addImage()`. This avoids browser CORS restrictions on direct SVG-to-canvas operations.

**Zoom-based icon tiers (MARKER_STYLES config object):**
- T1 icon shown at zoom < 13 (small, 24px)
- T2 icon shown at zoom ≥ 13 (medium, 32px)
- T3 icon shown on hover for bespoke features (large, 48px)
- T4 exists in files but is not yet wired into a layer

**Layer switch zoom:** `iconSwitch: 13` in `MARKER_STYLES` controls when T1 → T2 swap happens.

**Bespoke icons:** Configured in `MARKER_STYLES.peaks.bespoke` and `MARKER_STYLES.caves.bespoke`. Adding a new bespoke icon requires only a config entry — no layer code changes.

**Module export:**
```javascript
window.RMMMap = {
    init: function(containerId) { ... }
};
```
Dashboard embeds the map by calling `window.RMMMap.init('dashboard-map')`.

**Camera defaults (overrideable via style_config):**
```javascript
center: [18.4241, -33.9249]  // Cape Peninsula
zoom: 10
pitch: 45
bearing: 0
terrainExaggeration: 1.5
```

---

## 9. Map Build Stages

| Stage | Description | Status |
|---|---|---|
| 1 | GL JS foundation: 3D terrain, hillshade, fog, camera, style_config | Complete |
| 2 | Static data layers: GeoJSON, route lines, T1 markers, zones | Complete (peaks + caves GeoJSON; trails now API-driven via `trails` table) |
| 3 | Expression-driven styling: T1–T3 icons, grade colours, fire zones | Mostly complete (T1–T3 markers, grade colour `match` expression on routes, hover swaps, POI per-category icons; fire-zone layer pending) |
| 4 | Interaction: popups, hover effects, intro animation | Mostly complete (popups, hover, cluster fan-out, smart anchor, pulse all live; cinematic intro animation pending) |
| 5 | Animation system | Pending |
| 6 | Overlay illustrations (GPS-pinned) | Pending |
| 7 | Admin interface (separate Vercel deployment) | Pending |

---

## 10. Intelligence Engine Sequence (Non-Negotiable)

The four backend systems must be built in this order — each feeds the next:

```
Phase 1: GPS Stream Processor
    ↓
Phase 2: Route Grading Engine (Grade A–F, TDS 1–10)
    ↓
Phase 3: RPS — Running Performance Score (5 components, 90-day rolling)
    ↓
Phase 4: Race Readiness Indicator (5 checks, 3 verdicts)
```

**Phase 1 and Phase 2 are LIVE** — the public Route Analyzer at `/intelligence/routes` accepts GPX uploads and returns a full grade (A–F), TDS (1–10), effort descriptor, elevation profile, and activity stats. No auth required, no Supabase writes, no anti-gaming. **Phase 3 (RPS) and Phase 4 (Race Readiness) endpoints are deployed** and wired to their respective frontend pages (`/intelligence/fitness` and `/intelligence/readiness`). The Fitness page calls `/api/python/calculate-rps`, the Readiness page calls `/api/python/race-readiness`. Both require Strava login. Current blocker: 33 RPS formula env vars not yet set in Vercel — the early-return pattern means the pages show "0 / Foundation" gracefully rather than crashing. Once env vars are set and activities are synced, scoring will work.

**Trail Ecosystem (added 2026-05-19):** Separate from the intelligence engine sequence above, the Trail Ecosystem is the admin pipeline for curated trail content. Phases 1–3 of the [[trail_ecosystem_build_phases|6-phase trail ecosystem build]] are complete. Admin Trail Library is live at `/intelligence/trail-library` — GPX upload, grading (including descent grading via DDS), segment editing, rename, map preview, live/draft toggle. See [[trail_ecosystem_build_phases]] for full phase details.

---

## 11. CSS Design System

Defined in `styles/components.css` as CSS custom properties:

```css
--color-dark:   #171A14   /* dark olive — primary background */
--color-light:  #FFF1D4   /* papaya — primary text/surface */
--color-white:  #FFFFFF
--color-accent: #FF4E50   /* coral red — CTAs, active states */
--color-muted:  rgba(23, 26, 20, 0.5)
--font-mono:    'Space Mono', monospace
--nav-height:   64px
```

Mobile breakpoints: 768px (tablet), 480px (phone).

---

## 12. Icon Naming Convention (LOCKED)

```
t[state]-[category]-[slug].svg

t0  = single design, used at all zoom levels
t1  = zoom 8–12 (small, generic)
t2  = zoom 13+ (medium, generic)
t3  = hover/detail state (large, bespoke)
t4  = full-detail state (extra large, bespoke)

Directory: /public/icons/[category-plural]/
Slugs: lowercase, hyphen-separated
Category: must match the GeoJSON feature type (peaks, caves, events, pois, zones)
Format: SVG only — no PNGs, no @2x suffix
```
