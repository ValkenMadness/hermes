---
title: website_build_status_overview
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-21
updated_by: claude_cowork
tags: [codebase, build-status, pages, current-state]
supersedes: ""
related: ["[[website_build_status_issues]]", "[[website_architecture]]", "[[phased_build_plan]]", "[[launch_readiness_checklist]]"]
---

# Website Build Status — Pages and Sequence

**As of: 2026-05-21**

This document describes what is actually in the codebase and what it actually does. Not what it's meant to do — what it does now.

---

## Summary Table

| Area | Status |
|---|---|
| Map (core product) | ✅ Functional — all route popups working, cluster interactions complete |
| About | ✅ Complete |
| API (config + subscribe + engines) | ✅ Functional — 4 new Python endpoints added |
| Nav / Footer | ✅ Functional |
| Email overlay | ✅ Functional |
| Legal (Privacy, Terms, Cookies, AUP) | ✅ Written — draft notice on all |
| Intelligence sub-pages (Fitness, Routes, Readiness, RPS, Route Grading, Race Readiness) | 🟡 Routes has live GPX upload tool; Fitness + Readiness wired to live endpoints with three-state auth gating. `/intelligence/rps` — RPS deep-dive page with live score display. `/intelligence/route-grading` — full route grading tool with GPX upload, auth-gated saving, admin toggles, duplicate detection, route history. **NEW (2026-05-12):** `/intelligence/race-readiness` — full Race Readiness tool with route selector, verdict hero, five check cards, PI detail table, summary. Three-state auth gating. Show 0/Foundation until RPS env vars set + activities synced |
| Intelligence hub (`/intelligence`) | 🟡 Copy done — buttons now link to tool pages (RPS, Route Grading, Readiness). Images still needed. **Nav dropdown added (2026-05-11)** with sub-links to all three tool pages |
| Shop | 🟡 Layout done — no products, no checkout |
| Product page | 🟡 Template exists — broken (ignores URL param) |
| Leaderboards | 🟡 Explainer done — all data fake |
| Event page | 🟡 Template exists — fully hardcoded, no data |
| Dashboard | 🟡 Map panel works — auth-aware (Account Required badge when logged out, race number display when logged in). RPS + activity panels wired to live endpoints if Strava connected; events panel still fake |
| Authentication | ✅ Email/password auth LIVE (signup, signin, profile, race numbers, admin roles) + Strava OAuth LIVE (connect, link to user account). **Updated 2026-05-12:** Remember-me checkbox (30-day cookie), platform version enforcement (bump env var → all sessions invalidated), dual-table logout, nav auth persistence on all pages |
| GPS / Scoring engines | ✅ All four engines ported; Route Analyzer live with GPX upload |
| Supabase tables | ✅ users, athletes, activities, rps_scores, rps_history, route_analyses, trails, trail_segments, trail_pois, trail_poi_links, event_types all created (PostGIS enabled) |
| Strava activity sync | 🟡 Endpoint built (POST /api/auth/strava-activities) — not yet triggered; needs RPS env vars in Vercel first |
| Trail Library (admin) | ✅ Functional — GPX upload, grading (climb + descent), segment editor, rename, map preview, live/draft toggle, archive, POI linking. Admin-gated at `/intelligence/trail-library` |
| POI Manager (admin) | ✅ Functional — CRUD, 14 categories, 28 SVG icons (T1+T2), DDM coordinate converter, map preview modal, icon preview. Admin-gated at `/intelligence/poi-manager` |
| Trail Detail (public) | ✅ Functional — `/trail/:slug` public pages with grade cards, composite grades, elevation profile, mini-map, segments, linked POIs |
| Trail Browse (public) | ✅ Functional — `/trails` page with filterable/sortable trail cards. Public discovery page |
| Map POI layer | ✅ Functional — POIs render on map with per-category T1/T2 icons, hover popup (name only), click detail popup, filter sidebar toggle |
| 404 page | ✅ On-brand error page with nav/footer |
| Admin interface | 🟡 Admin role system live (auto-grant for Valken, grant-to-others via profile page). Trail Library + POI Manager are live admin tools. Dedicated admin dashboard not started |
| Strava / Garmin integration | 🟡 Strava OAuth done — activity sync endpoint built but not yet triggered; Garmin not yet |
| Payment (Stripe) | ❌ Not started |

---


## Page-by-Page Status

---

### `/` and `/map` — The Map

**What it's supposed to do:** Full-page interactive map of the Cape Peninsula. 3D terrain, all peaks and caves as markers, all graded routes as overlaid lines with popups, email capture overlay.

**What it actually does:**
- Map initialises via `/api/config` (fetches Mapbox token + style URL from Vercel env vars)
- 3D terrain renders (DEM source + terrain defined in Mapbox Studio style)
- Atmospheric fog renders correctly
- Contour lines render if `CONTOURS_TILESET_ID` env var is set
- Trail network renders if `TRAILS_TILESET_ID` env var is set
- All peaks from `peaks.geojson` render as T1/T2 generic SVG markers, with T3 bespoke hover for Maclear's Beacon (see bug below)
- All caves from `caves.geojson` render as T1/T2 generic SVG markers, with T3 bespoke hover for Boomslang Cave (both entrances)
- Route data now loaded from API (`/api/python/trails?action=list`) instead of static GeoJSON files (migrated 2026-05-19). All `status='live'` trails from Supabase render on the map
- Route lines are now **hidden by default** (`line-opacity: 0`) and revealed only when the corresponding marker is hovered. The previous always-visible-at-50%-opacity behaviour is gone.
- Each route's start coordinate gets a marker. Trails that share a start (rounded to 5 dp) collapse to one DOM cluster primary; on hover it fans out one secondary per trail. Single-trail starts continue to render via the `rmm-route-starts` GL circle layer.
- Hover behaviour: cursor change, line + label reveal via filter on `rmm-routes-highlight` and `rmm-route-labels`, pulse dot animation along the route. Cluster secondaries now have full parity: popup, pulse, and highlight all work on hover.
- Route start-dot popup opens on hover — **all stats now render correctly** (grade, distance, elevation gain, elevation density). Fixed 2026-04-27 by merging `crs.properties` metadata into each Feature's `properties` at load time.
- Popup positioning is now smart: `getPopupAnchorAwayFromTrail()` detects the trail's initial direction on screen and places the popup on the opposite side to avoid overlapping the pulse animation.
- Email capture overlay shows on first visit (suppressed by `localStorage.rmm_subscribed`)
- Admin gate works: `?admin=madmaps` sets `localStorage.rmm_admin`, `?admin=reset` clears it
- Navigation controls (zoom in/out) present top-right
- **Filter sidebar** (added 2026-04-27): collapsible left panel with toggle switches for all layer groups — Peaks, Caves, RMM Routes, Trails (Paths/Tracks/Footways/Steps), Contour Lines. Placeholder toggles for Events, POIs, and Zones (disabled, greyed out). Opened via layers icon button top-left. Closes via X, Escape, or clicking the map. All layers start visible; no persistence across sessions. Route toggle also hides DOM cluster markers and stops pulse animation.
- `window.RMMMap.init(containerId)` public API works — used by dashboard

**What's missing or incomplete:**
- `og-image.png` referenced in OG/Twitter meta tags but does not exist in `/public/images/`
- Intro flyover / cinematic camera animation not implemented (DEFAULTS gives a static starting position)
- No mobile-specific touch optimisation in the popup UX
- `style_config` live overrides from Supabase work for camera position and terrain exaggeration only — no other map properties are overrideable at runtime

**Completed since last update (2026-05-21):**
- Route popup now shows event type badge, road percentage, and "View trail details →" link (replaces "Route details coming soon")
- Route popup has 350ms linger delay + mouse-over-popup detection so users can click the link
- Event type labels display as human-readable (e.g. "Hill Climb" not "hill_climb") via `_eventLabel()` helper
- POI layer renders with per-category T1/T2 icons, name-only hover popup, click-to-detail popup
- POI filter toggle added to sidebar (no longer placeholder)
- All map data (trails + POIs) loads from API endpoints, not static GeoJSON files

---

### `/about` — About

**What it's supposed to do:** Platform mission, the four engine systems, grading methodology, RPS detail, race readiness detail, founder bio.

**What it actually does:** Fully written, real substantive content. All 10 sections populated with final copy. Static page, no dynamic data. Functional.

**What's missing:** Nothing. This page is complete.

---

### `/intelligence` — Intelligence Hub

**What it's supposed to do:** Landing/overview page for the three intelligence tools (Fitness Indicator, Route Analyzer, Race Readiness Indicator), with feature highlights for each.

**What it actually does (as of 2026-05-01):** Structure, layout and **copy** all done. Real h1, subtitle, tool names (Runner Performance Score / Objective Route Grading / Race Readiness Check), real two-column descriptions for each tool, and three descriptive USP h4s per tool feature strip. CTAs link correctly to `/intelligence/fitness`, `/intelligence/routes`, `/intelligence/readiness`. Secondary CTA labels reflect engine state — Routes shows "Live Now →", Fitness and Readiness show "Coming Soon →". Committed locally as `ad1db2c content: replace all placeholder copy on /intelligence hub`.

**What's missing:** USP / feature-strip illustrations (image placeholders still empty). Page is gated behind admin (`localStorage.rmm_admin`) so it's not public-facing yet.

**Updated 2026-05-11:** Three tool buttons now link to their respective pages: "Full Breakdown →" → `/intelligence/rps`, "Grade a Route →" → `/intelligence/route-grading`, "Check Readiness →" → `/intelligence/readiness`. "Explore" buttons unchanged, still link to detail/explainer pages.

---

### `/intelligence/fitness` — Fitness Indicator

**What it's supposed to do:** Deep-dive explainer on the Runner Performance Score: five components, athlete levels, CTA to connect Strava/Garmin. When authenticated, shows live RPS score.

**What it actually does (as of 2026-05-08):** Real content. Five components with correct weights. Athlete level bands (Foundation through Elite) with correct ranges. **Now wired to live backend:** when logged in with Strava connected, calls POST `/api/python/calculate-rps` with athlete's `strava_athlete_id`. Shows loading → score display → empty state flow. **Three-state CTA system:** logged-out users see "Sign Up to View" linking to /signup; logged-in users without Strava see "Connect Strava to see your score"; logged-in with Strava see live RPS section. Sync Activities button triggers POST `/api/auth/strava-activities` to pull last 90 days.

**Current state:** Endpoint returns 0/Foundation (no activities synced yet). The RPS formula env vars are NOT yet set in Vercel — the endpoint has an early-return for zero activities to avoid crashing on missing env vars. Once env vars are added and activities are synced, this page will show real scores.

**What's missing:** RPS env vars in Vercel (93 total — template ready in `vercel-paste-ready.txt`). First activity sync hasn't been triggered yet. Garmin integration not started.

---

### `/intelligence/routes` — Route Analyzer (Explainer)

**What it's supposed to do:** Deep-dive on the route grading system, validated route table, GPX upload tool.

**What it actually does:** Real content. Grade system grid (A through F with descriptions). Validated routes table with correct real data for 7 routes. CTA has "Coming Soon" badge.

**What's working (as of 2026-04-27):** GPX upload tool is LIVE. Drag-and-drop upload area with activity type selector (Trail/Road/Hike). Uploads GPX to `/api/python/analyze`, runs GPS Stream Processor + Route Grader, returns grade card with difficulty class (A–F), TDS (1–10), effort descriptor, route type tag, stats grid (distance, gain, ED, climbs), and SVG elevation profile. No auth required — public anonymous tool. Formula env vars loaded into Vercel production via CLI.

**What's still missing:** No route details page to link from results. No saved history of analyzed routes. Fitness and Readiness tools still static explainers.

---

### `/intelligence/rps` — RPS Deep-Dive (NEW 2026-05-11)

**What it's supposed to do:** Full breakdown of the Runner Performance Score with live score display for authenticated users.

**What it actually does (as of 2026-05-11):** Deep-dive page for RPS. Shows five scoring components with correct weights. Athlete level bands (Foundation through Elite). When logged in with Strava connected, calls `/api/python/calculate-rps` and displays live score. Three-state auth gating (logged out → sign up, logged in no Strava → connect, Strava connected → live data).

**CSS prefix:** `rps-page-` in `pages.css`.

**What's missing:** Same dependency as fitness page — needs RPS env vars + activity sync for real scores.

---

### `/intelligence/route-grading` — Route Grading Tool (NEW 2026-05-11)

**What it's supposed to do:** Interactive route grading tool with GPX upload, saving, admin controls, duplicate detection, and route history.

**What it actually does (as of 2026-05-11):** Full route grading tool page with five functional sections:

1. **Public GPX Upload:** Drag-and-drop with activity type selector. Calls `/api/python/analyze` — no auth required. Returns grade hero (A–F, TDS 1–10), stats grid, SVG elevation profile.
2. **Auth-Gated Saving:** Logged-in users can save graded routes to Supabase via `/api/python/upload`. Saved routes feed the map and race readiness systems.
3. **Admin Toggles:** Two switches visible only to admin (`user.role === 'admin'`):
   - "Show on Map" — `show_on_map` boolean on activities table
   - "Include in Race Readiness" — `include_in_readiness` boolean on activities table
   Both toggle via POST JSON to `/api/python/upload` with `action=toggle`.
4. **Duplicate Detection:** After saving, checks for existing GPX with start point within 200m (haversine) and distance within 10%. Shows comparison alert with merge option. Merge averages metrics and marks secondary as `purpose=merged`.
5. **Route History:** Table of all previously analyzed routes for the user, fetched via GET `/api/python/upload?action=history&athlete_id=X`. Shows grade, distance, elevation, date. Admin users see additional "Map" and "Readiness" toggle columns.

**Backend:** `api/python/upload.py` extended to 482 lines with GET+POST multi-action routing (no new serverless function — stays within 12-function Vercel Hobby limit).

**CSS prefix:** `rg-` in `pages.css` (~475 lines).

**Supabase schema additions (SQL provided, pending execution):**
- `activities.show_on_map` — boolean, default false
- `activities.include_in_readiness` — boolean, default false
- `activities.merged_from` — jsonb, default null

**What's missing:** Supabase columns not yet created (SQL provided). Admin toggle and merge functionality untested on production until columns exist.

---

### `/intelligence/readiness` — Race Readiness Indicator (Explainer)

**What it's supposed to do:** Deep-dive explainer on the Race Readiness engine, five checks, three verdicts, CTA to run the check. When authenticated, shows live readiness assessment for a selected route.

**What it actually does (as of 2026-05-08):** Real content. Five checks explained correctly. READY/CLOSE/NOT YET verdicts displayed. **Now wired to live backend:** when logged in with Strava connected, shows route selector dropdown and calls GET `/api/python/race-readiness?route_id=X&athlete_id=Y`. **Same three-state CTA system as fitness page:** logged-out → "Sign Up to View", logged-in no Strava → "Connect Strava", Strava connected → live readiness section.

**Current state:** Shows "Unable to assess readiness" because no activities are synced (the readiness engine needs training activities to compare against a route). Same dependency chain as fitness: needs RPS env vars → activity sync → then readiness will work.

**What's missing:** Same as fitness — env vars + first sync. Also depends on having graded routes in `route_analyses` table (the readiness engine compares your training against a specific route's grade).

---

### `/intelligence/race-readiness` — Race Readiness Tool (NEW 2026-05-12)

**What it's supposed to do:** Full interactive Race Readiness tool with route selection, live verdict display, five check cards with detail breakdowns, and PI detail table.

**What it actually does (as of 2026-05-12):** Deep-dive tool page for Race Readiness. Five functional sections:

1. **Route Selector:** Dropdown populated from graded routes in `route_analyses` table via `/api/python/race-readiness` (list mode, no `route_id`). Shows route name, grade badge, distance, and elevation gain.
2. **Verdict Hero:** Large verdict display (READY/CLOSE/NOT YET) with checks-passed count and colour-coded styling (green/amber/red).
3. **Five Check Cards:** Grid of cards for distance_coverage, volume_load, performance_index, recency, elevation_coverage. Each shows pass/fail status, progress bar, computed target vs actual values, and expandable detail breakdown.
4. **Route Info Card:** Selected route's grade, distance, elevation gain, elevation density, effort descriptor.
5. **PI Detail Table:** Performance Index breakdown showing all qualifying activities with their PI scores, distances, times, and grades.
6. **Summary Message:** Engine-generated narrative summary of the readiness assessment.

**Three-state auth gating:** Same pattern as RPS and Route Grading pages — logged out → sign up CTA, logged in no Strava → connect CTA, Strava connected → live tool.

**API calls:** `loadGradedRoutes()` fetches route list, `runReadinessCheck()` calls `/api/python/race-readiness?route_id=X&athlete_id=Y`. Activity sync available via `syncForReadiness()`.

**CSS prefix:** `rr-` in `pages.css` (~300 lines).

**What's missing:** Same dependency as the explainer page — needs graded routes in the DB and synced activities for meaningful results.

---

### `/intelligence/trail-library` — Trail Library (NEW 2026-05-19)

**What it's supposed to do:** Admin-only trail management hub — upload GPX files, grade trails (including descent grading), manage segments with per-km notes and tags, rename trails, preview on map, toggle live/draft, archive.

**What it actually does (as of 2026-05-19):** Full admin trail management tool with six functional areas:

1. **GPX Upload + Grading:** Drag-drop GPX upload with event type selector (trail, time trial, hill climb, hill bomb). Processes via GPS Stream Processor + Route Grader V3 + Descent Grader. Returns composite grade (overall + climb grades + descent grades), stats grid (distance, gain, ED, climbs), SVG elevation profile. Trail saved as draft automatically.
2. **Trail Library Table:** All trails listed with name, type, grade, distance, gain, status. Filterable by status (all/draft/live/archived) and event type. Each row has action buttons: Go Live/Unpublish, Rename, Segments, View on Map, Archive.
3. **Segment Editor Modal:** Click "Segments" to open per-km breakdown. Each segment card shows km range, gradient, gain/loss, and editable fields: notes (free text), surface type (1–5 scale), track width (1–3), exposure (1–3), terrain toggle (trail/road). Terrain scrub bar visualises trail vs road distribution. Snip tool extracts a km range as a new independent draft trail.
4. **Rename Feature:** Two entry points — inline edit after upload (pencil icon), prompt-based rename in table. Both update name + slug via API.
5. **Map Preview:** "View on Map" opens a modal with Mapbox GL JS rendering the trail line on a 3D map. Token fetched from existing mapconfig endpoint.
6. **Live/Draft Toggle:** One-click toggle per trail. When toggled to live, trail appears on the main map (page refresh). Unpublish returns to draft.

**Backend:** `api/python/trails.py` — consolidated endpoint handling all trail and segment CRUD via `?action=` routing. Admin auth via `rmm_session` cookie → `users.session_token` lookup. Auto-generates per-km segments on trail creation.

**CSS prefix:** `tl-` (trail library), `seg-` (segment editor) in `pages.css`.

**Database:** `trails` table (with PostGIS geometry), `trail_segments` table, `event_types` table. All created via Phase 1 migration.

**Env vars:** 16 DDS env vars deployed to Vercel (weights, grade thresholds, normalisation ceilings, detection thresholds).

**What's missing:** POI association per segment (Phase 5). Trail detail public page (Phase 5). Multi-GPX merge for geometry refinement (deferred). Activity type auto-detection from road/trail percentage (Phase 6). Some styling polish needed on segment editor modal.

---

### `/intelligence/poi-manager` — POI Manager (NEW 2026-05-20)

**What it's supposed to do:** Admin-only POI management hub — create, edit, and delete map points of interest with custom icons, coordinates, and categories.

**What it actually does (as of 2026-05-21):** Full admin POI management tool with five functional areas:

1. **POI Creation Form:** Name, category (14 types), coordinates (decimal OR DDM format with auto-converter), elevation, description, status (draft/live). Icon preview updates dynamically when category changes.
2. **DDM Coordinate Converter:** Paste Garmin DDM format (e.g. `S34°06.6719' E018°25.4460'`) and it auto-converts to decimal lat/lon. Handles N/S/E/W hemispheres.
3. **POI Library Table:** All POIs listed with name, category, coordinates, status. Each row has action buttons: Edit, Toggle Live/Draft, Delete, View on Map.
4. **Edit Modal:** Opens pre-populated form for editing any POI field. Updates via API.
5. **Map Preview Modal:** "View on Map" opens Mapbox GL JS modal showing POI location with T2 category icon on 3D terrain.

**Backend:** All CRUD operations route through `api/python/trails.py` via `?action=` routing: `create-poi`, `update-poi`, `delete-poi`, `list-all-pois` (admin), `pois` (public live-only).

**CSS prefix:** `poi-` in `pages.css`.

**What's missing:** Dynamic category management (admin UI to add/edit categories without code changes — planned for future). Icon redesign (Valken will design bespoke icons before introducing POIs to the public ecosystem).

---

### `/trail/:slug` — Trail Detail (NEW 2026-05-21)

**What it's supposed to do:** Public trail detail page showing the full trail breakdown — grade, stats, elevation profile, mini-map, segments, linked POIs.

**What it actually does (as of 2026-05-21):** Full public trail detail page with seven sections:

1. **Hero:** Trail name, event type badge, grade card (letter + TDS + effort descriptor) with grade-coloured background.
2. **Composite Grades:** Climb and descent grade cards showing individual segment grades.
3. **Stats Grid:** Distance, elevation gain/loss, elevation density, climb count, min/max elevation.
4. **Surface Bar:** Road vs trail percentage.
5. **Elevation Profile:** SVG profile chart (reuses the trail-library elevation profile pattern).
6. **Mini-Map:** Embedded Mapbox GL JS map showing the trail line with start (green) and end (red) markers on 3D terrain.
7. **Segments:** Per-segment cards showing km range, type, gradient, gain/loss, grade, and admin notes.
8. **Linked POIs:** Cards for each associated POI with T2 category icon, name, km position, elevation, and description.

**API:** `GET /api/python/trails?action=get-trail&slug=<slug>` — public endpoint returning trail + segments + linked POIs. Only returns `status=live` trails. Returns 404 for non-existent or non-live trails.

**Routing:** `vercel.json` rewrite: `{ "source": "/trail/:slug*", "destination": "/pages/trail.html" }`. Slug extracted from URL path in JS.

**CSS prefix:** `td-` (trail detail) in `pages.css`.

---

### `/trails` — Trail Browse (NEW 2026-05-21)

**What it's supposed to do:** Public trail discovery page where visitors can browse all live graded trails.

**What it actually does (as of 2026-05-21):** Full public trail browse page with:

1. **Filters:** Grade (A–F), event type (trail, time trial, hill climb, hill bomb), sort (name, hardest first, longest, most climb).
2. **Trail Count:** Shows "X trails" matching current filters.
3. **Card Grid:** Responsive grid of trail cards, each showing: grade badge (colour-coded), event type label, trail name, description excerpt, stats (distance, gain, m/km, TDS), road/trail surface split, "View details →" link.
4. **Empty State:** "No trails match your filters" when filters exclude all trails.

**API:** `GET /api/python/trails?action=browse` — lightweight public endpoint returning live trails without coordinates (name, slug, grade, stats only). Seasonal filtering applied server-side.

**CSS prefix:** `tb-` (trail browse) in `pages.css`.

---

### `/intelligence/trail-library` — Trail Library (Updated 2026-05-21)

Previously documented. **New additions since 2026-05-19:**

- **POI Linking Section:** Added to the segment editor modal. Admin can link existing POIs to a trail at specific km positions. Select POI from dropdown, enter km position, click Link. Linked POIs display as removable chips with unlink button. Uses `?action=link-poi`, `?action=unlink-poi`, `?action=trail-pois` endpoints.
- **Map Preview Modal:** "View on Map" button in the library table opens Mapbox GL JS modal showing trail line on 3D terrain (was previously documented as complete, confirmed working).

---

### `/shop` — Shop

**What it's supposed to do:** Product listing for Cape Peninsula map prints, merch, event medals.

**What it actually does:** Layout correct. Four product cards (Cape Peninsula Trail Map, RMM Trail Tee, Peak Hunter Cap, Event Medal Collection). Each links to `/product?id=[slug]`. All four show "Coming Soon" badge. All four have placeholder image areas (no images). Pricing: map is R495–R695 (the only real price), tee and cap are "TBD", medal is "Included with event entry". Page intro copy contains "Placeholder — short intro." visible in the HTML.

**What's missing:** Product images. Real merch definitions and pricing. Checkout / payment. No product data comes from Supabase or any dynamic source — all hardcoded in HTML. This page is gated behind admin.

---

### `/product` — Product Detail

**What it's supposed to do:** Individual product detail page, driven by `?id=` URL parameter, showing images, specs, pricing, buy CTA.

**What it actually does:** Template exists with correct two-column layout (image area + details). Always shows "Cape Peninsula Trail Map" regardless of which product link was clicked — the page does not read the `?id` URL parameter at all. Product images are a placeholder div with "Image Coming Soon" badge. Three thumbnail slots exist (empty). Buy button is `disabled` with text "Pre-Order Coming Soon". Related products section hardcoded to Trail Tee, Peak Hunter Cap, Event Medal.

**What's missing:** Any dynamic product loading. URL param `?id` is completely ignored. All product data is hardcoded HTML. No Stripe integration. No checkout flow. Breadcrumb is hardcoded to "Cape Peninsula Trail Map" regardless of which product is being viewed.

---

### `/leaderboards` — Leaderboards

**What it's supposed to do:** Live GPS-verified leaderboards from official RMM events.

**What it actually does:** Real explainer content about how leaderboards work (anti-gaming rules, leaderboard types). Three leaderboard type cards (Per-Route Records, Event Results, Seasonal Standings) all tagged "Coming Soon". Sample table preview shows "Chase the Dragons Tail" with five rows of "Athlete Name" placeholder data and placeholder times/paces. No real data. No data fetching. This page is gated behind admin.

**What's missing:** All real data. All event data. No Supabase queries. No filtering. The entire functional leaderboard system.

---

### `/event` — Event Detail

**What it's supposed to do:** Individual event page with route info, entry tiers, entry button, live results.

**What it actually does:** Single template, hardcoded to "Chase the Dragons Tail". Grade badge hardcoded to "Challenge Grade · B · 7/10". Stats hardcoded (12.4 km, 486m gain, 39.2 m/km, 7/10, Sustained Climb). Event description is visible placeholder text ("Placeholder — A 2-3 line description..."). Event window: "Open: TBD — Close: TBD". Entry tiers show R49.95 for Base, "TBD" for Standard and Premium. Entry button is `disabled` with "Enter Event — Coming Soon". Map preview and elevation profile are empty divs with text labels inside ("Route map preview", "Elevation profile"). Results section shows "Coming Soon".

**What's missing:** Everything dynamic. URL param not read — page doesn't know which event it's for. No event data from Supabase. No actual route map preview. No elevation profile. No entry/payment flow. No results.

---

### `/dashboard` — Dashboard

**What it's supposed to do:** Logged-in user's trail intelligence hub — map panel, upcoming events, recent activity, RPS score, race readiness, lifetime stats, Peak Hunter progress, Cave Diver progress.

**What it actually does:**
- **Map panel**: works. Loads the map engine via `window.RMMMap.init('dashboard-map')`. Map renders correctly in the embedded panel.
- **Events panel**: shows 3 hardcoded event cards ("Chase the Dragons Tail", "The Elephants View", "Dancing with the Devil"). All placeholder copy ("A brief 2 liner about the challenge"). "Sign up" links to `#`. Leaderboard links to `/leaderboards`.
- **Recent Activity**: 3 hardcoded activity cards with fake data ("Mastering the 5k - LAP #012", "Ou Wa Pad Sprint", etc.). Fake distances, paces, times. "Learn More" links to `#`.
- **Runner Performance Score panel**: header only. Body div is empty. No content.
- **Race Readiness panel**: header only. Body div is empty. No content.
- **Lifetime Summary panel**: header only. Body div is empty. No content.
- **Peak Hunter panel**: header only. Body div is empty. No content.
- **Cave Diver panel**: header only. Body div is empty. No content.
- "Welcome back, [Name]" — shows first name when logged in (via RMMAuth). Shows "Account Required" badge and Sign Up link when logged out.
- Race number displayed for logged-in users.
- RPS and activity panels only load data if Strava is connected.

**What's missing:** All panel bodies (RPS, readiness, peak hunter, cave diver, lifetime summary). Activity panel wired but shows Strava data only. Events panel still hardcoded. This page is gated behind admin.

---

### `/legal` — Legal Index

**What it's supposed to do:** Index of all four policies.

**What it actually does:** Clean index page with links to privacy, terms, cookies, acceptable-use. Functional.

---

### `/privacy` — Privacy Policy

**What it's supposed to do:** Full POPIA-compliant privacy policy.

**What it actually does:** Fully written. 12 sections with real substantive content covering data collection, Strava/Garmin scope, storage locations, retention periods, POPIA rights, etc. Effective date: 10 April 2026. Has a visible DRAFT NOTICE explaining the policy has not yet been reviewed by a South African attorney.

**What's missing:** Attorney review. Draft notice needs to be removed after review.

### `/terms`, `/cookies`, `/acceptable-use`

These pages exist and have legal content (confirmed to have full `<body>` content though not fully read). Not confirmed whether they also carry a draft notice.

---


## What the Public Actually Sees

With admin gate not set, the public nav shows three items: **Map**, **Trails**, and **About**. The rest (Shop, Intelligence, Leaderboards, Dashboard) are invisible.

So from a public-facing standpoint, the live site is:

1. `/` — The map (functional, with POI markers + trail popups linking to detail pages)
2. `/trails` — Trail browse page (filterable/sortable grid of all live graded trails)
3. `/trail/:slug` — Individual trail detail pages (grade, stats, profile, map, segments, POIs)
4. `/about` — Complete explainer page
5. `/signup` — Athlete registration with race number assignment
6. `/signin` — Login form
7. `/profile` — Athlete profile (redirects to sign-in if not logged in)
8. `/intelligence/routes` — Route Analyzer with live GPX upload tool (public, no auth required)
9. `/privacy`, `/terms`, `/cookies`, `/acceptable-use` — Legal pages
10. Any unmatched URL → Custom 404 page ("Trail not found")

Nav shows Map, Trails, About, and Sign In for unauthenticated visitors. Logged-in users see Profile instead of Sign In. Admin users additionally see Shop, Intelligence (with dropdown sub-menu: Fitness Score RPS, Route Grading Tool, Race Readiness, Trail Library, POI Manager), Leaderboards, and Dashboard.

---


## Engine Build Sequence — Current Status

From `CLAUDE.md`:

> Phase 1: GPS Stream Processor → Phase 2: Route Grading → Phase 3: RPS → Phase 4: Race Readiness

**Current status: Phases 1–2 LIVE, Phases 3–4 ported AND wired to frontend (2026-05-05). RPS/Readiness pages show auth-gated live sections. Scoring blocked on: (1) RPS env vars not yet in Vercel, (2) no activities synced yet.** All engine code lives in `api/python/`. GPS Stream Processor, Route Grading V3, RPS Engine, Race Readiness Engine, Anti-Gaming Validator, and Descent Grader are ported as Vercel Python serverless functions. Five API endpoints created: `/api/python/upload` (public+authed, absorbed analyze.py), `/api/python/trails` (admin trail CRUD), `/api/python/calculate-rps`, `/api/python/race-readiness`, `/api/python/recalculate-decay`. Config reads from Vercel env vars via `_LazyDescriptor` pattern (deferred loading — only reads env vars when first accessed, preventing import crashes when unused engine vars are missing). DEM falls back to GPS altitude (no SRTM on Vercel). Supabase REST API used for all data operations (no SDK). All 55 route grading + 16 DDS formula env vars are set in Vercel Production environment. The public Route Analyzer at `/intelligence/routes` is live and functional. The admin Trail Library at `/intelligence/trail-library` is live with full GPX → grade → segment edit → publish pipeline.

**Trail Ecosystem (2026-05-21):** Separate 6-phase build for the admin trail content pipeline. **All 6 phases COMPLETE.** Phase 1: Database Foundation. Phase 2: Admin Route Analyzer Core. Phase 3: Admin Route Analyzer Advanced. Phase 4: POI System (28 icons, CRUD, map layer). Phase 5: Trail Detail Pages + Trail-POI Linking. Phase 6: Public Trail Browse + 404 + Polish. See [[trail_ecosystem_build_phases]] and [[trail_ecosystem_design]] for details.

---


## Map Build Stages — Current Status

From `CLAUDE.md`:

| Stage | Description | Status |
|---|---|---|
| Stage 1 | Foundation (GL JS, 3D terrain, hillshade, fog, camera, style_config) | ✅ Complete |
| Stage 2 | Static Data Layers (GeoJSON, route lines, T1 markers, zones) | ✅ Complete |
| Stage 3 | Expression-Driven Styling (T1–T3, tier icons, grade colours, fire zones) | 🟡 Partial — T1–T3 markers, hover, **and grade colour match expression** all live (route lines now coloured A–F via `match` on `properties.grade`); fire zones not implemented |
| Stage 4 | Interaction, Popups, Intro Animation | 🟡 Partial — single-trail hover + popup + pulse all working; cluster fan-out refined (2026-04-30); **filter sidebar (2026-04-27)** with layer toggles for all categories including POIs; **route popup updated (2026-05-21)** with event type badge, road percentage, "View trail details →" link, 350ms linger delay for clickability; **POI popups (2026-05-20)** with name-only hover + click-to-detail; intro flyover animation not implemented |
| Stage 5 | Animation System | ❌ Not started (beyond the existing pulse dot on route hover) |
| Stage 6 | Overlay Illustrations | ❌ Not started |
| Stage 7 | Admin Interface | ✅ Trail Library live (admin-gated) with full segment editor + POI linking. POI Manager live (admin-gated) with CRUD + map preview. |
