---
title: website_build_status_issues
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-22
updated_by: claude_cowork
tags: [codebase, build-status, bugs, technical-debt]
supersedes: ""
related: ["[[website_build_status_overview]]", "[[website_architecture]]", "[[security_audit_findings_2026_05_22]]", "[[completion_report_audit_2026_05_22]]", "[[launch_readiness_checklist]]"]
---

# Website Build Status — Issues and Technical Debt

**As of: 2026-05-22**

This document describes what is actually in the codebase and what it actually does. Not what it's meant to do — what it does now.

---

## Recently Found (2026-05-22 audit)

These are the audit findings from the 2026-05-22 read-only pass. See [[security_audit_findings_2026_05_22]] for the structured reference and [[completion_report_audit_2026_05_22]] for the full handover.

### 2026-05-22 — Formula IP exposed in tracked files (Critical)

**Files (all tracked at repo root):** `vercel-paste-ready.txt` (153 lines), `HANDOVER-RPS-ENV-VARS.md` (254 lines), `vercel-env-template.txt` (102 lines), `set-env-vars.ps1` (74 lines), `RMM_Route_Analyzer_Env_Vars.xlsx` (34 rows), `vercel-dds-env-vars.txt` (16 lines).

**What's exposed:** All 93+ formula env vars with values — every weight, threshold, benchmark, the full `BASE_CLASS_MATRIX` JSON, DDS components, RPS cross-discipline bonus, decay. Trade-secret values per [[core_principles]] and [[ip_protection]].

**Why it's not fixed by `git rm` alone:** Removing from HEAD does not remove from history. Cleanup requires `git filter-repo` (or BFG) + force-push.

**Status:** First logged 2026-05-07 as NEW-40 (then covering only 3 files). Brain has known the full scope since 2026-05-22. Not fixed.

**Fix sequence:** Confirm GitHub repo visibility → `git rm` all six → add to `.gitignore` → `git filter-repo` → force-push. ~90 min. Cross-link [[master_task_list]] NEW-46 and [[launch_readiness_checklist]] #52.

### 2026-05-22 — `.gitignore` UTF-16 encoding bug (Critical)

**File:** `.gitignore`

**Symptom:** Last line of `.gitignore` is UTF-16-encoded. Git reads `.gitignore` as UTF-8 — the rule does not match. Six `.pyc` files currently tracked in `api/python/__pycache__/`: `_config`, `_descent_grader`, `_gps_processor`, `_supabase`, `trails`, `upload`.

**Why subtle:** The file looks right when opened in an editor. `xxd` reveals null bytes interleaving every character of the bottom rule (`0061 0070 0069 002f ...` = `a.p.i./...`). A previous commit (`d390808`) cleared the `__pycache__` directory but didn't fix the `.gitignore`, so the files regenerate on every Python edit.

**Fix:** Re-save `.gitignore` as UTF-8 (no BOM, LF line endings). `git rm -r --cached api/python/__pycache__`. Commit. ~15 min.

### 2026-05-22 — Strava OAuth `state` parameter is not a CSRF token (Critical)

**Files:** `api/auth/strava-login.js`, `api/auth/strava-callback.js`

**Symptom:** `strava-login.js:39` puts the user's `return_to` URL into the OAuth `state` parameter. `strava-callback.js` decodes `state` and redirects without verification against any stored nonce.

**Exploit (account-linking CSRF):** (1) Attacker authorises Strava with their own account, captures the resulting `code` from the redirect URL. (2) Attacker crafts a link to `/api/auth/strava-callback?code=ATTACKER_CODE&state=/profile`. (3) Victim (already logged into RMM via email/password) clicks. (4) Callback upserts attacker's Strava athlete record. (5) Callback reads victim's session cookie, writes `strava_athlete_id = ATTACKER_STRAVA_ID` onto victim's user row. (6) Victim's RMM account is now linked to attacker's Strava — RPS pollution, identity blur, support headache.

**Fix:** Generate random nonce at login, sign with HMAC (`state = HMAC(secret, nonce + return_to)`), store in signed cookie, verify on callback. Reject if absent or mismatched. ~30 min. See [[oauth_and_api_compliance]] (updated 2026-05-22).

### 2026-05-22 — Missing security headers (High)

**File:** `vercel.json`

**Symptom:** Headers array sets `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin`. Missing: `Content-Security-Policy`, `Strict-Transport-Security` (Vercel may set by default — needs assertion), `Permissions-Policy`. XSS blast radius is wide because 39 `innerHTML` sites and 9 inline `<script>` blocks exist across the JS and HTML.

**Fix:** Add the three missing headers. CSP baseline suggested in [[launch_readiness_checklist]] #57. ~30 min.

### 2026-05-22 — Working-tree drift (High, transient)

**Symptom:** 24 files modified locally, not committed. Surface includes 5 auth files (`account.js`, `session.js`, `strava-callback.js`, `strava-activities.js`, `auth.js`), 6 Python engines (`_anti_gaming.py`, `_dem_lookup.py`, `_race_readiness.py`, `_route_grader.py`, `_rps_engine.py`, `_supabase.py`), 6 HTML pages (`dashboard.html`, `profile.html`, `signin.html`, `signup.html`, three intelligence pages), 2 SQL migration files, `vercel-paste-ready.txt`, `RMM_State_of_the_Build_2026-05-07.md`, `.claude/settings.local.json`.

**Why it matters:** Local production does not match deployed production. If the laptop fails those changes are lost. Brain status notes track deployed state, so any uncommitted work isn't reflected.

**Fix:** For each file, either `git diff` → commit (clear message) → push, or `git checkout --` to discard. ~30–60 min review depending on intent.

### 2026-05-22 — `public/data/routes/` directory still in repo

**Files:** `public/data/routes/.gitkeep`, `public/data/routes/DELETE_THESE_FILES.md`

**Symptom:** Phase 1 handoff (`rmm/_work/_handoffs/phase1_database_map_migration.md`, 2026-05-19) listed this directory for `git rm`. Map is correctly API-driven now (`/api/python/trails?action=list`), but the relic directory + marker file are still tracked.

**Fix:** `git rm -rf public/data/routes/`. ~1 min.

---

## Recently Fixed

### 2026-05-11 — CSS brace imbalance broke all page styling (Critical)

**File:** `styles/pages.css`

**Symptom:** All page styling broken on production. Every page except `/map` had no CSS applied.

**Root cause:** The file had 3 leftover `=======` git conflict markers from a prior merge and triple-duplicated content — 8898 lines when it should have been ~3400. The conflict markers created an imbalance of 1364 open braces vs 1361 close braces, causing cascading CSS parse failures.

**Fix:** Rebuilt the file from scratch: kept lines 1–2954 (original content) + lines 6391–6834 (RPS styles from a prior session), discarding all duplicated sections and conflict markers. Result: 3399 lines, 599 open braces, 599 close braces — perfectly balanced.

**Lesson logged:** Always verify CSS brace balance after merges. The conflict markers were invisible to casual inspection because they were deep in the file. A simple `grep -c '{' file` vs `grep -c '}' file` check would have caught this immediately.

### 2026-05-11 — File tool vs bash mount sync issue (Tooling)

**Files affected:** `upload.py`, `vercel.json`, `pages.css`

**Symptom:** Changes made via Cowork's Edit/Write file tools were not visible to the bash sandbox mount. The bash mount showed stale content — e.g., `upload.py` showed only 257 lines (truncated mid-string) after Edit tool had written 482 lines.

**Root cause:** The file tools and bash sandbox use different filesystem paths/mounts with imperfect sync.

**Fix:** Rewrote all three files via bash heredoc/cat commands instead of using Edit/Write tools. Verified each with appropriate validators (`py_compile` for Python, `json.load()` for JSON, brace counting for CSS).

**Lesson logged:** When file tool changes need to be validated or consumed by bash operations, write via bash instead. The file tools are reliable for reads but writes may not propagate to the bash sandbox mount immediately.

### 2026-05-11 — Route grading tool page and upload.py multi-action API

**Files:** `pages/intelligence-route-grading.html` (NEW), `api/python/upload.py` (rewritten), `vercel.json` (updated), `styles/pages.css` (appended)

**What was done:** Built a full route grading tool at `/intelligence/route-grading`. Extended `upload.py` from POST-only to GET+POST with action routing to avoid creating a new serverless function (at 12/12 Vercel Hobby limit). Added ~475 lines of `rg-` prefixed CSS. Added vercel.json rewrite. See [[handoff_route_grading_and_nav_2026_05_11]] for full details.

### 2026-05-11 — Intelligence hub buttons updated and nav dropdown added

**Files:** `pages/intelligence.html` (3 lines), `scripts/components.js` (nav dropdown), `styles/components.css` (dropdown CSS)

**What was done:** (1) Updated three tool buttons on `/intelligence` to link to actual tool pages instead of showing "Coming Soon" / "Live Now". (2) Added a dropdown menu under the Intelligence nav link with sub-links to Fitness Score (RPS), Route Grading Tool, and Race Readiness. Desktop uses CSS hover, mobile uses JS click-to-toggle. See [[handoff_route_grading_and_nav_2026_05_11]] for full details.

**Status:** Live on production.

---

### 2026-05-12 — Auth hardening: remember-me, platform version, dual-table logout, nav auth

**Files:** `api/auth/account.js`, `api/auth/session.js`, `api/auth/logout.js`, `pages/signin.html`, `scripts/components.js`, `styles/pages.css`

**What was done (four fixes):**

1. **Remember-me checkbox on sign-in:** Added "Remember me for 30 days" custom-styled checkbox to `/signin`. When checked, cookie gets `Max-Age=2592000` (30 days). When unchecked, session cookie (cleared on browser close). Signup always sets 30-day cookie.

2. **Platform version enforcement:** New `RMM_PLATFORM_VERSION` env var (set in Vercel). Stamped into `session_version` column on users table at login/signup. On every session check (`/api/auth/session`), if stored version doesn't match current env var, session is invalidated and user must re-login. Bumping the env var immediately forces all users to sign in again — useful for terms changes or breaking updates.

3. **Dual-table logout:** `logout.js` previously only cleared `session_token` from the `athletes` table. Now clears from BOTH `users` and `athletes` tables, and also clears `session_version` on users.

4. **Nav auth persistence on all pages:** `components.js` previously only knew auth state on pages that loaded `auth.js` (7 pages). All other pages defaulted to showing "Sign In" even when logged in. Fixed by adding `applyNavAuthState()` helper that does a lightweight `/api/auth/session` fetch when `auth.js` isn't present.

**Additional fix:** Sign-in page session detection was using `document.cookie.indexOf('rmm_session')` which never works because the cookie is HttpOnly. Replaced with direct `/api/auth/session` API call.

**Supabase migration (executed 2026-05-12):** `ALTER TABLE users ADD COLUMN IF NOT EXISTS session_version text;`

**Vercel env var (set 2026-05-12):** `RMM_PLATFORM_VERSION=1.0`

**Status:** Live on production.

---

### 2026-05-12 — Race Readiness full tool page

**Files:** `pages/intelligence-race-readiness.html` (NEW), `styles/pages.css` (appended ~300 lines `rr-` prefix), `vercel.json` (new rewrite), `pages/intelligence.html` (button href update), `scripts/components.js` (nav dropdown link update)

**What was done:** Built `/intelligence/race-readiness` — the full interactive Race Readiness tool. Route selector, verdict hero (READY/CLOSE/NOT YET), five check cards with progress bars and detail breakdowns, route info card, PI detail table, summary message. Three-state auth gating. Same pattern as RPS and Route Grading full pages.

**Status:** Live on production.

---

### 2026-05-12 — Nav dropdown hover gap fix

**Files:** `styles/components.css`

**What was done:** Intelligence nav dropdown disappeared when moving the mouse from "Intelligence" to the dropdown items. Root cause: `margin-top: 12px` on `.nav-dropdown-menu` created dead space between trigger and menu. Fixed by replacing `margin-top` with `padding-top: 1rem` and adding an invisible `::before` pseudo-element hover bridge (12px tall, full width).

**Status:** Live on production.

---

### 2026-05-06 — Supabase athlete_id UUID→TEXT type fix (Critical)

**Tables:** `activities`, `rps_scores`, `rps_history`

**Symptom:** Activity sync returned 27 errors / 0 synced. RPS calculation returned 500. Both hit the same PostgreSQL error: `22P02: invalid input syntax for type uuid: "32748372"`.

**Root cause:** The `activities` table was created (2026-04-25) with `athlete_id` as UUID type. The Strava sync and RPS endpoints send Strava's numeric athlete ID as a text string (e.g., `"32748372"`), which PostgreSQL rejects when the column expects UUID format.

**Fix (Supabase SQL Editor):** Dropped `activities_athlete_id_fkey` foreign key constraint (linked to `athletes.id` which is UUID), then altered `athlete_id` to TEXT on all three tables. Ran `NOTIFY pgrst, 'reload schema'` to refresh PostgREST cache. After fix, activity sync succeeded (27 activities) and RPS calculation returned a real score.

**Lesson logged:** When the codebase sends Strava numeric IDs as identifiers, the database column must be TEXT, not UUID. Always verify column types match what the application actually inserts. The FK between activities and athletes is now dropped — acceptable because they use different ID schemes (Strava numeric vs internal UUID).

### 2026-05-06 — RPS cross-discipline bonus percentage bug

**File:** `api/python/rps_engine.py` — line 372

**Symptom:** Overall RPS showed 100 / Elite when individual discipline scores were 25–28.

**Root cause:** `CROSS_DISCIPLINE_BONUS_PCT=5` (meaning 5%) was used as a raw multiplier: `bonus = weighted_avg * 5 ≈ 125`, capped to 100. Should have been `weighted_avg * 0.05 ≈ 1.25`.

**Fix:** Changed `bonus = weighted_avg * bonus_pct` to `bonus = weighted_avg * (bonus_pct / 100.0)`. After fix, overall RPS correctly shows 28 / Active.

### 2026-05-06 — Race Readiness dynamic route selector (replaces hardcoded routes)

**Files:** `api/python/race_readiness_check.py`, `pages/intelligence-readiness.html`

**Symptom:** Readiness page had 7 hardcoded GeoJSON route slugs. These are map display routes, not database entries. Backend looked up by database `id` → every selection returned 404/500.

**Fix:** (a) Added "list mode" to the race-readiness endpoint — when `route_id` is omitted, returns graded routes from `route_analyses` + `activities` tables. Avoids needing a new serverless function (at 12/12 limit). (b) Replaced hardcoded array in the HTML with `loadGradedRoutes()` that fetches from the list mode endpoint. Shows "No graded routes yet — upload a GPX on the Routes page" when empty (correct current state).

**Status:** Edited locally, needs commit + push.

### 2026-05-05 — Supabase tables created for RPS scoring pipeline

**Tables:** `activities`, `rps_scores`, `rps_history`, `route_analyses`

**Symptom:** Python endpoints (`/api/python/calculate-rps`, `/api/python/race-readiness`) returned 500 because the tables they read from didn't exist.

**Fix:** Created SQL migration split into multiple parts (Supabase SQL Editor runs scripts as a single transaction — if any statement fails, column additions roll back). The `activities` table already existed from an older build with a different schema, so migration used `ALTER TABLE ADD COLUMN IF NOT EXISTS` pattern. Similarly `rps_scores` and `rps_history` existed with missing columns; migration added columns idempotently.

**Lesson logged:** Supabase SQL Editor atomic transactions mean you must split large migrations. Always use `IF NOT EXISTS` for columns and tables. After ALTER TABLE, run `NOTIFY pgrst, 'reload schema'` to refresh PostgREST cache.

### 2026-05-05 — RPS endpoint early-return for zero activities

**File:** `api/python/calculate_rps.py`

**Symptom:** Endpoint 500'd even with tables present because `Config` class raises `ValueError` for any missing env var when the RPS engine is instantiated — and 33 RPS formula env vars weren't yet set in Vercel.

**Fix:** Added early-return check after the activities query: if no activities are found, return `{rps: 0, activity_count: 0, level: {name: "Foundation", ...}}` immediately without instantiating the engine. This means the Fitness page shows "0 / Foundation" gracefully rather than crashing. Once env vars are set and activities synced, the engine will run normally.

### 2026-05-05 — Strava callback reverted from debug mode to production redirects

**File:** `api/auth/strava-callback.js`

**Symptom:** During debugging, the callback was returning JSON error bodies instead of redirecting to `/map?auth=error`. This left users on a blank JSON page if upsert failed.

**Fix:** Reverted both the upsert failure handler and the exception handler to use `res.writeHead(302, { Location: '/map?auth=error' }).end()` with `console.error` for diagnostics.

### 2026-05-01 — `/intelligence` hub placeholder copy replaced

**File:** `pages/intelligence.html`

**Symptom:** Three prior AI sessions (Codex, two Claude Code briefs) had been asked to replace developer placeholder text on the `/intelligence` hub. All three reported success without verifying via git; the file on `dev` HEAD still contained `USP 1`/`USP 2`/`USP 3`, "Captivating H1 and H2", "This is a block…", and "This can be a nice graphic…".

**Fix:** Real copy now in place across the entire page — h1 ("Know the mountain. Know your limits."), subtitle, three tool sections (Runner Performance Score / Objective Route Grading / Race Readiness Check) with two-column descriptions and three descriptive USP h4s per feature strip. Secondary CTA labels reflect engine state: Routes "Live Now →", Fitness/Readiness "Coming Soon →". Structure, class names, IDs unchanged.

**Verification:** `grep -nE "USP [0-9]|Captivating|This is a block|This can be a nice graphic" pages/intelligence.html` returns zero matches. Committed locally as `ad1db2c content: replace all placeholder copy on /intelligence hub`. Push to `origin/dev` blocked from sandbox (no GitHub credentials in workspace) — Valken to push from local terminal so Vercel auto-deploys.

**Lesson logged:** Subsequent AI sessions must verify via the full sequence: `git diff` → `git add` → `git commit` → `git push` → `git log --oneline -3` before reporting success. Three AIs in a row stopped after the edit step. The third committed but never pushed.

### 2026-04-30 — Maclear's Beacon T3 icon filename apostrophe fixed (Bug 2 closed)

**File:** `public/icons/peaks/`, `scripts/map.js`

**Symptom:** T3 hover icon for Maclear's Beacon never rendered — `fetch()` 404'd silently and the map fell back to the T2 base icon.

**Fix:** Renamed the SVG on disk from `t3-peak-maclear's-beacon.svg` to `t3-peak-maclears-beacon.svg` (apostrophe removed). `MARKER_STYLES.peaks.bespoke["Maclear's Beacon"].t3.file` already pointed at the apostrophe-less name, so no JS change was needed. Same rename applied to the `t4-` companion file. Committed as `1a98108 fix: commit Maclear's Beacon icon rename (remove apostrophe from filename)`.

### 2026-04-30 — Curtain-page dead code removed

**Files:** `scripts/main.js`, `styles/main.css`

**Symptom:** Both files lingered from the pre-launch curtain page and were not loaded by any HTML page. They risked being mistakenly edited by future contributors looking for "main" entry points.

**Fix:** Deleted both files. Committed as `35b6a56 chore: remove orphaned curtain page files (main.js, main.css)`. The "Orphaned / Legacy Files" section in [[website_key_files]] has been dropped accordingly.

### 2026-04-30 — Grade colour match expression added to route lines

**File:** `scripts/map.js` — `loadRMMRoutes()`

**Symptom:** Every route line was `#FF4E50` regardless of grade — Stage 3 was supposed to colour each grade A–F differently.

**Fix:** Replaced the hardcoded `'line-color': '#FF4E50'` on `rmm-routes` with a `match` expression keyed on `properties.grade`, returning the canonical grade colour for A through F with a fallback. The expression is verified live in the Vercel-deployed `map.js`. Stage 3 status in [[website_build_status_overview]] updated from "grade colours not implemented" to "grade colour match expression live".

### 2026-04-30 — Cluster fan-out refined to brief, mobile gap closed, zoom-scale parity

**Files:** `scripts/map.js` (`loadRMMRoutes()` — `expandCluster`, `collapseCluster`, primary creation, new helpers), `styles/map.css` (cluster section).

**What changed (cumulative):**

1. **Fan-out math reworked.** Previous arc was 10 o'clock → 4 o'clock via the top (`arcStart = -5π/6`, `arcSweep = π`), which placed the first and last children on opposite sides of the parent — flagged in the brief as wrong. New geometry: children orbit starting at 9 o'clock and stepping clockwise at a fixed 40° gap (`startAngle = π`, `step = 40° · i`), with a fall-back to even spacing around a full circle (`step = 2π / n`) when `n > 9`. Tight upper-arc cluster for typical n=2–5; never overshoots for large n. Radius bumped 22 → 26 px to keep clearance between the now full-size children.
2. **Parent shrinks 30 % on expand.** Implemented as a CSS transition (`scale(0.7)` over 240 ms) on a new wrap/inner DOM structure (`.rmm-cluster-primary-wrap` > `.rmm-cluster-primary`) so the scale doesn't fight Mapbox's positional `translate`.
3. **Children render at the original (full) marker size.** Was 10 px, now 14 px content + 2 px border each side = 18 px visible — same primitive as the GL singletons.
4. **Cluster popup always hangs below the device.** Anchored to the parent's `lngLat` (not the hovered child) with `anchor: 'top'`. Edge fallback flips to `'bottom'` (popup floats above) when the parent is within ~160 px of the bottom of the map viewport so the card isn't clipped.
5. **Mobile / touch support.** `click` on primary expands; `click` on secondary selects (mirrors `mouseenter`); `map.on('click')` collapses if the tap landed off the cluster; `map.on('movestart')` collapses when the user pans or zooms (the fan is in pixel space and would otherwise drift).
6. **Zoom-scale parity with GL singletons.** New `computeClusterPrimaryScale(zoom)` mirrors the GL `rmm-route-starts` `circle-radius` interpolation (3 → 5 → 7 across zooms 8 → 12 → 15 plus 2 px stroke). `syncClusterScale()` writes the result to `--rmm-cluster-scale` on `<html>`, and the CSS rules for primary, secondary, `is-expanded`, and the fan-in keyframes all consume it so cluster markers stay pixel-matched to the GL singletons at every zoom. Fixes the previously oval-looking primary at low zoom.
7. **Animations and accessibility.** Staggered fan-in keyframes (220 ms with overshoot, 30 ms-per-index delay) and `@media (prefers-reduced-motion: reduce)` to disable the bouncy entrances.

**Lesson logged:** Mapbox writes inline `transform: translate(...)` on the marker element. If you also want to scale or rotate the marker visually, wrap it — the wrap takes the translate, the inner takes the scale. Otherwise CSS transforms overwrite Mapbox's positioning.

### 2026-04-25 — MultiLineString crash hid peaks, caves, and trails

**File:** `scripts/map.js` — `loadRMMRoutes()` and `addDataLayers()`

**Symptom:** Peak and cave markers disappeared from the map; route lines never revealed on hover. No console-visible failure of the layer adds — peaks and caves simply never reached `addLayer`.

**Root cause:** Every route GeoJSON in `public/data/routes/` uses `"type": "MultiLineString"` (coordinates nested 3 levels deep). `loadRMMRoutes()` was written assuming `LineString` and read `coords[0][0]` / `coords[0][1]` as `lng` / `lat`. For MultiLineString those are both arrays. Cascade:

1. `startFeatures` got malformed `[[lng,lat,ele],[lng,lat,ele]]` Point geometries.
2. The cluster grouper did `Math.round(c[0] * 1e5)` where `c[0]` was now an array → `NaN`. Every feature collapsed to one bucket keyed `"NaN,NaN"`.
3. `mapboxgl.Marker.setLngLat(...)` threw on the malformed coords.
4. The throw escaped `loadRMMRoutes()`, which is `await`ed inside `addDataLayers()`, so `addPeakLayers()` and `addCaveLayers()` never ran.

**Fix:** Two changes in `scripts/map.js` —
1. Added `flattenLineCoords(geom)` and `getFirstPoint(geom)` helpers that handle both `LineString` and `MultiLineString`. Used them when building `startFeatures` and `window._rmmRouteCoords`.
2. Wrapped `await loadRMMRoutes()` in `try/catch` inside `addDataLayers()` so any future route-loading failure can't silently block peak/cave layer adds. Caught errors log as `RMM: loadRMMRoutes failed —`.

**Lesson logged:** Geometry-type assumptions in handler code should always be guarded — exporters routinely emit MultiLineString from GPX even when only one segment is present. Any future GeoJSON consumer should use `flattenLineCoords` / `getFirstPoint` rather than indexing `coordinates` directly.

### 2026-04-27 — Route popup stats blank (Bug 1 resolved)

**File:** `scripts/map.js` — `loadRMMRoutes()`

**Symptom:** When hovering a route start dot, the popup opened but `grade_display`, `distance_km`, `elevation_gain_m`, and `elevation_density` all rendered as empty strings.

**Root cause:** Route GeoJSON files store all metadata in `data.crs.properties` — a non-standard field on the FeatureCollection root. `loadRMMRoutes()` only read `data.features`, where each Feature's `properties` contained only `name` and null GPX fields.

**Fix:** Added a merge step in `loadRMMRoutes()` that copies `crs.properties` fields into each Feature's `properties` at load time. No GeoJSON files were edited — the fix is JS-side only. Fields merged: `name` (as `display_name`), `grade`, `tds`, `distance_km`, `elevation_gain_m`, `elevation_density`, `grade_display`, `effort_descriptor`.

### 2026-04-27 — Cluster interaction system completed

**Files:** `scripts/map.js`, `styles/map.css`

**What was done (cumulative):**
1. Cluster secondaries now have full popup + pulse + highlight parity with single-trail starts
2. Fan-out radius tightened to 22px (from original 52px) — *superseded 2026-04-30 (now 26 px to fit full-size children)*
3. Fan layout changed from full 360° circle to 180° semi-arc, 10 o'clock → 4 o'clock — *superseded 2026-04-30 (now starts at 9 o'clock, fixed 40° gap CW, full-circle fallback for n>9)*
4. Collapse debounce timer increased to 350ms (from 150ms) for usability
5. Invisible SVG hover bridge polygon added between primary and all children
6. Hover aura pseudo-element (`::before`) on secondaries added then removed (interfered with positioning)

### 2026-04-27 — Smart popup anchor positioning added

**File:** `scripts/map.js` — `getPopupAnchorAwayFromTrail()`

**What it does:** Samples the trail's first ~10 coordinates, projects start and sample point to screen space, calculates the trail's initial direction angle, and sets the popup anchor to the opposite side. Prevents the popup from overlapping the pulse animation.

### 2026-04-27 — Pulse animation made zoom-independent

**File:** `scripts/map.js` — `startRoutePulse()`

**Symptom:** Animation appeared faster when zoomed in because step interval was fixed while screen-space distance between coordinates increased with zoom.

**Fix:** Replaced fixed `Math.floor(4000 / total)` interval with per-step delay calculated from screen-space pixel distance: `delay = Math.max(16, Math.round(dist / PX_PER_MS))` where `PX_PER_MS = 0.08` (~80 px/s). Dot now moves at constant visual speed regardless of zoom level.

---


## Known Bugs

### Bug 2 — OG image missing (functional impact: low)

**File:** `pages/map.html` lines 13–17

**What happens:** `og:image` and `twitter:image` meta tags reference `/public/images/og-image.png` but the file does not exist. Social media link previews show no image.

**Fix:** Create and place an `og-image.png` in `/public/images/`.

---

### Bug 3 — Product page ignores URL param (functional impact: medium)

**File:** `pages/product.html`

**What happens:** `/product?id=trail-tee` and `/product?id=cape-peninsula-map` both show identical hardcoded "Cape Peninsula Trail Map" content. The `?id` param is never read.

**Fix:** When product data is defined, add a small inline script to read `new URLSearchParams(window.location.search).get('id')` and render the correct product.

---


## Hardcoded Values That Need to Be Dynamic

| Value | Where It Appears | Should Come From |
|---|---|---|
| "Welcome back, Runner" | `dashboard.html` line 32 | Logged-in user's first name |
| Event names in dashboard events panel | `dashboard.html` lines 66, 82, 98 | Supabase events table |
| Event descriptions in dashboard | `dashboard.html` lines 68, 84, 100 | Supabase events table |
| "Chase the Dragons Tail" throughout | `event.html`, `leaderboards.html`, `dashboard.html` | Supabase events table |
| Event stats (12.4 km, 486m, etc.) | `event.html` lines 52–65 | Supabase events table |
| "Open: TBD — Close: TBD" | `event.html` line 74 | Supabase events table |
| Entry prices (R49.95, TBD) | `event.html` lines 80–89 | Supabase events / pricing table |
| Activity cards in dashboard | `dashboard.html` lines 119–210 | Strava/Garmin data |
| Product content | `product.html` | Product data source (TBD) |
| Sample leaderboard rows | `leaderboards.html` lines 84–119 | Supabase leaderboard table |
| "Athlete Name" in leaderboard preview | `leaderboards.html` | Supabase results table |

---


## Features Scaffolded but Not Wired Up

| Feature | Where | What's Done | What's Missing |
|---|---|---|---|
| ~~GPX upload / grade tool~~ | ~~`/intelligence/routes`~~ | ~~DONE 2026-04-25 — Route Analyzer live with drag-drop GPX, full grade result display~~ | — |
| ~~Fitness score display~~ | ~~`/intelligence/fitness`~~ | ~~DONE 2026-05-06 — Page live with real RPS score (28/Active from 27 Strava activities). Sync button works. All env vars set.~~ | — |
| Race readiness check | `/intelligence/readiness` | Page wired to `/api/python/race-readiness`, dynamic route selector fetches graded routes from DB | Needs at least one graded route uploaded via `/intelligence/route-grading` to test against |
| ~~Route grading tool~~ | ~~`/intelligence/route-grading`~~ | ~~DONE 2026-05-11 — Full tool page with GPX upload, auth-gated saving, admin toggles, duplicate detection, route history~~ | Supabase columns (`show_on_map`, `include_in_readiness`, `merged_from`) pending — SQL provided |
| Event entry / payment | `/event` | Button exists (disabled) | Stripe integration, entry management |
| Pre-order / purchase | `/product` | Button exists (disabled) | Stripe integration, order management |
| ~~Newsletter subscribe CTAs~~ | ~~`/intelligence`~~ | ~~Done 2026-05-01 — secondary CTAs now reflect engine state ("Live Now →" / "Coming Soon →"); standalone "Subscribe" button removed during copy replacement~~ | — |
| Route details page | Route popup in map | "Coming soon" text in popup | A page that exists at, say, `/route?id=Elsies-Peak-Route-1` |
| ~~Cluster secondary popup~~ | ~~Map cluster fan-out~~ | ~~Done 2026-04-27~~ | ~~Secondaries now open full route popup on hover~~ |
| ~~Cluster secondary pulse~~ | ~~Map cluster fan-out~~ | ~~Done 2026-04-27~~ | ~~Secondaries now trigger pulse animation on hover~~ |
| ~~Mobile tap on clusters~~ | ~~Map cluster fan-out~~ | ~~Done 2026-04-30~~ | ~~`click` handlers on primary/secondary wraps; tap-outside collapses via `map.on('click')`; pan/zoom collapses via `map.on('movestart')`~~ |
| Dashboard RPS panel | `dashboard.html` | Panel shell (header div) | All content |
| Dashboard Race Readiness panel | `dashboard.html` | Panel shell (header div) | All content |
| Dashboard Lifetime Summary | `dashboard.html` | Panel shell (header div) | All content |
| Dashboard Peak Hunter | `dashboard.html` | Panel shell (header div) | All content |
| Dashboard Cave Diver | `dashboard.html` | Panel shell (header div) | All content |
| Dashboard Recent Activity | `dashboard.html` | Layout exists with fake data | Real data from Strava/Garmin or Supabase |
| Event map previews | `event.html`, `dashboard.html` | Placeholder divs | Actual static map images or embedded mini-maps |
| Elevation profile | `event.html` | Placeholder div | SVG/canvas chart from route GeoJSON |

---


## Dead Code

None outstanding. The two pre-launch curtain files (`scripts/main.js`, `styles/main.css`) were deleted on 2026-04-30 (commit `35b6a56`).

---


## Not Started (no code exists)

These features are defined in the product spec and legal documents but have zero implementation in the current codebase:

- ~~**Authentication system** — DONE 2026-05-03. Strava OAuth login via `api/auth/strava-login.js`. Session management via httpOnly cookie + Supabase `athletes` table. `scripts/auth.js` client module. No signup page needed (Strava IS the signup).~~
- ~~**User accounts** — PARTIAL 2026-05-03. Athletes table created with profile fields from Strava. No profile page or account settings yet.~~
- ~~**Strava / Garmin OAuth** — STRAVA LIVE 2026-05-06. OAuth flow, token storage, auto-refresh, and activity sync all working. 27 activities synced with GPS→GPX conversion. Garmin not started.~~
- ~~**GPS Stream Processor** — DONE. Deployed as part of `api/python/gps_processor.py`. Used by analyze and upload endpoints.~~
- ~~**Route Grading Engine** — DONE. `api/python/route_grader.py` + `/api/python/analyze` endpoint LIVE.~~
- ~~**Runner Performance Score engine** — LIVE 2026-05-06. `api/python/rps_engine.py` + `/api/python/calculate-rps` endpoint. All 33 env vars set. First real score: 28/Active from 27 Strava activities.~~
- ~~**Race Readiness Engine** — WIRED 2026-05-06. `api/python/race_readiness.py` + `/api/python/race-readiness` endpoint. Backend + frontend connected with dynamic route selector. Needs graded routes to fully test.~~
- ~~**Anti-gaming validation pipeline** — DONE. `api/python/anti_gaming.py` deployed. Runs during authed uploads.~~
- **Admin interface** — `modules/` directory contains only `.gitkeep`.
- **Payment (Stripe)** — referenced in Privacy Policy. No Stripe keys, no payment API, no checkout.
- **Event registration system** — no backend for accepting entries, managing participants, or running results.
- **Leaderboard data pipeline** — no mechanism for creating or populating leaderboard entries.
- **Athlete profiles** — no public or private profile pages.
- **Email marketing system** — subscribers go into Supabase `subscribers` table. No mechanism for sending emails (no SendGrid, Mailgun, etc. integrated).
- **Cookie consent banner** — Cookie Policy page exists but no consent management UI is implemented.
- **Account deletion flow** — described in Privacy Policy as "hard purge within 30 days". No mechanism exists.

---
