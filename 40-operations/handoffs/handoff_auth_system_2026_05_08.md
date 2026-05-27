---
title: handoff_auth_system_2026_05_08
domain: rmm
type: handoff
status: active
created: 2026-05-08
updated: 2026-05-08
updated_by: claude_cowork
tags: [handoff, auth, signup, profile, admin, vercel-consolidation]
supersedes: ""
related: ["[[website_architecture]]", "[[website_build_status_overview]]", "[[handoff_strava_oauth_complete]]"]
---
# Handoff — Email/Password Auth System (2026-05-08)

## What Was Done

Built the full email/password authentication system for the RMM platform. This is the primary signup path for athletes — Strava OAuth remains as a secondary connection mechanism, not a login method.

### New Files Created
- `api/auth/account.js` — Consolidated endpoint handling signup, signin, and admin-grant via `?action=` query parameter. Consolidation required by Vercel Hobby plan 12-function limit.
- `pages/signup.html` — Registration form (first name, last name, email, gender, age, password, confirm password). Success state shows race number reveal card with RMM-XXXXXX display.
- `pages/signin.html` — Email + password login. Supports `?return_to=` URL param for post-login redirect.
- `pages/profile.html` — Athlete profile with race number card, account details, Strava connection panel, admin controls (admin-only), sign out.
- `supabase_users_migration.sql` — SQL migration for `users` table (already executed in Supabase).

### Modified Files
- `api/auth/session.js` — Now checks `users` table first, falls back to `athletes` table. Also serves map config via `?type=mapconfig` (consolidated from deleted `api/config.js`).
- `api/auth/strava-callback.js` — Dual-mode: if user is logged in via users table, links Strava to their account. Otherwise falls back to legacy athlete-only flow.
- `scripts/auth.js` — Major rewrite. Handles both `data.user` and `data.athlete` responses. New methods: `isAdmin()`, `isStravaConnected()`, `getAuthSource()`, `signup()`, `connectStrava()`. Login redirects to `/signin` instead of Strava OAuth.
- `scripts/components.js` — Nav shows Sign In / Profile links based on auth state. Admin-only pages injected dynamically for admin users.
- `pages/intelligence-fitness.html` — Three-state CTA: sign up / connect Strava / live data.
- `pages/intelligence-readiness.html` — Same three-state CTA pattern.
- `pages/dashboard.html` — Auth-aware: Account Required badge for logged-out, race number display for logged-in. RPS/activity panels only load if Strava connected.
- `styles/pages.css` — CSS for auth pages, profile, race number reveal, admin controls, Strava connection badge.
- `vercel.json` — Added routes for /signup, /signin, /profile. Added rewrite for /api/config → session.js?type=mapconfig.

### Vercel Hobby Plan Consolidation
The Vercel Hobby plan limits deployments to 12 serverless functions. To stay under the limit:
1. **Python helpers renamed with underscore prefix** — `config.py` → `_config.py`, `supabase.py` → `_supabase.py`, etc. (8 files). Vercel ignores `_`-prefixed files. All imports updated.
2. **Auth endpoints consolidated** — `signup.js`, `signin.js`, `admin-grant.js` merged into `account.js` with `?action=` routing.
3. **Map config consolidated** — `api/config.js` merged into `session.js` via `?type=mapconfig` query param.
4. **Final count: exactly 12 serverless functions** (7 JS + 5 Python endpoints).

**FUTURE TODO:** When upgrading to Vercel Pro, reverse the consolidation — split `account.js` back into separate files, restore `config.js`, and rename Python helpers back to non-prefixed names. The consolidated version works fine but separate files are easier to maintain.

### Database
- `users` table created in Supabase with RLS enabled.
- Columns: id (UUID), email (unique), password_hash, first_name, last_name, gender, age, race_number (unique), role, strava_connected, strava_athlete_id, session_token, created_at, updated_at, last_login.
- Indexes on session_token, email, race_number, strava_athlete_id.

### Key Design Decisions
- **No npm dependencies** — password hashing uses Node.js built-in `crypto.scryptSync` (salt + hash stored as `salt:hash`).
- **Race numbers** — `RMM-XXXXXX` format (100000–999999), random with collision check loop (10 attempts).
- **Admin auto-grant** — `valkenrunningmad@gmail.com` gets `role: 'admin'` on signup.
- **Dual auth** — `session.js` checks `users` table first, then `athletes` table for backward compatibility with existing Strava-only sessions.
- **Three-state intelligence pages** — Logged out → "Sign Up to View", logged in no Strava → "Connect Strava", Strava connected → live data.

### What's NOT Changed
- Newsletter lightbox on map page — untouched.
- Strava OAuth flow for legacy athletes — still works as fallback.
- All existing Python engine endpoints — functionality unchanged (only import paths updated for underscore prefix).
- Map functionality — unchanged.

## Context Files
- [[website_architecture]] — Updated with full auth documentation
- [[website_build_status_overview]] — Updated with auth status across all pages
- [[platform_architecture_and_tech_stack]] — Reference (not updated this session)

## Next Steps
- Set the 33 remaining RPS formula env vars in Vercel (prepared in `vercel-paste-ready.txt`)
- Trigger first Strava activity sync after env vars are set
- Test the full signup → connect Strava → view RPS flow end-to-end on production
- Consider Garmin OAuth integration
- Upgrade to Vercel Pro when revenue justifies it, then reverse the function consolidation
