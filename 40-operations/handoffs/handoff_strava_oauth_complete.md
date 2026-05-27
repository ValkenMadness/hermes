---
title: handoff_strava_oauth_complete
domain: rmm
type: handoff
status: active
created: 2026-05-03T00:00:00.000Z
updated: 2026-05-03T00:00:00.000Z
updated_by: claude_opus_cowork
tags: [handoff, strava, oauth, authentication]
supersedes: ""
related: ["[[website_build_status_overview]]", "[[website_architecture]]", "[[master_task_list]]", "[[launch_readiness_checklist]]"]
---

# Handoff — Strava OAuth Complete (2026-05-03)

## What Was Done

Strava OAuth 2.0 integration built and deployed to production in a single evening session.

### Files Added to Repo

| File | Purpose |
|---|---|
| `api/auth/strava-login.js` | Redirects to Strava consent screen. Scopes: `read,activity:read`. |
| `api/auth/strava-callback.js` | Exchanges auth code for tokens, upserts athlete in Supabase, sets httpOnly session cookie, redirects to dashboard. |
| `api/auth/session.js` | Returns current athlete (public fields only). Auto-refreshes expired Strava tokens (5-min buffer). |
| `api/auth/logout.js` | Invalidates session in Supabase, clears cookie, redirects to /map. |
| `scripts/auth.js` | Client-side auth module. `window.RMMAuth` with `.check()`, `.login()`, `.logout()`, `.onReady()`, `.updateUI()`. |
| `supabase_athletes_migration.sql` | Creates/alters athletes table with OAuth + session columns. RLS enabled. |

### Commit

`5cbbe98` feat: Strava OAuth flow — login, callback, session, logout

Merged dev → main. Production deployment confirmed READY: `dpl_HMthdPy7wJCDnQntVq6B56DsJuE8`.

### Strava App Details

- Client ID: 163342
- Callback domain: runmadmaps.com
- Category: Training
- Env vars: `strava_oauth_client_id`, `strava_oauth_client_secret` (both set in Vercel production)

### Security Audit

Full audit completed on all files for PUBLIC GitHub repo. Results: APPROVED.

- All secrets from `process.env` only
- Tokens never returned to client (session.js explicitly selects safe fields only)
- httpOnly + Secure + SameSite=Lax cookies
- crypto.randomUUID() for session tokens
- RLS on athletes table — anon key blocked
- No CORS issues

### Verified

- Valken successfully authorized Strava on production (runmadmaps.com)
- Athlete record created in Supabase
- Session cookie set
- Redirect to /dashboard working

---

## What's Next

The OAuth spine is in place. The next session should connect it to the intelligence tools:

### Priority 1 — Wire Activity Data Pipeline

1. **Build `/api/auth/strava-activities.js`** — fetch recent activities from Strava API using the stored access token
2. **Feed activities through GPS Stream Processor** (`api/python/gps_processor.py` — already ported)
3. **Feed processed data through RPS Engine** (`api/python/rps_engine.py` — already ported)
4. **Store results in Supabase** — update athletes.rps_current, create activity_scores table

### Priority 2 — Light Up Intelligence Pages

5. **Fitness Indicator page** (`/intelligence/fitness`) — replace "Coming Soon" CTA with live RPS score display for logged-in athletes
6. **Race Readiness page** (`/intelligence/readiness`) — wire to `api/python/race_readiness_check.py` with route selector
7. **Dashboard** — populate RPS panel, Recent Activity panel, Race Readiness panel with real data

### Priority 3 — Strava Webhook

8. **Register Strava webhook** (Task #137) — POST to `https://www.strava.com/api/v3/push_subscriptions`
9. **Build webhook handler** — receives activity create/update/delete events, triggers GPS processing pipeline automatically
10. **Initial 90-day sync** (Task #139) — on first connection, backfill recent activity history

### Priority 4 — Garmin

11. **Apply for Garmin developer access** (Task #21) — approval takes days/weeks, start early
12. **Implement Garmin OAuth** (Task #142) — separate flow, same session pattern

### Deferred

- Strava deauthorisation handler (Task #146) — needed before launch but not urgent
- Cookie consent banner — Cookie Policy page exists but no consent UI
- Account deletion flow (POPIA) — described in Privacy Policy, no mechanism yet

---

## Key Decisions Made

1. **No Supabase Auth SDK** — using lightweight custom session (cookie + athletes table) instead. Simpler, no dependencies, fits the vanilla JS architecture.
2. **Strava as primary login** — no separate email/password registration. Athletes authenticate via Strava, which creates their account.
3. **30-day session cookie** — balances convenience with security. `Max-Age: 2592000`.
4. **Auto token refresh** — session.js refreshes Strava tokens transparently when they're within 5 minutes of expiry. Athletes never see "token expired" errors.
5. **Full dev branch merged to main** — all accumulated work from sessions 1–5 now live on production. Public still sees only Map and About (admin gate intact).
