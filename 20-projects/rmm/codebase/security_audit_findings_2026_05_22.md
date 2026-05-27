---
title: security_audit_findings_2026_05_22
domain: rmm
type: knowledge
status: active
created: 2026-05-22
updated: 2026-05-22
updated_by: claude_cowork
tags: [security, audit, codebase, reference, ip, oauth]
supersedes: ""
related: ["[[website_architecture]]", "[[website_build_status_issues]]", "[[ip_protection]]", "[[oauth_and_api_compliance]]", "[[popia_compliance]]", "[[launch_readiness_checklist]]", "[[master_task_list]]", "[[completion_report_audit_2026_05_22]]", "[[audit_2026_05_22]]"]
---
# Security Audit Findings — 2026-05-22

Standing reference for the security findings of the 2026-05-22 read-only audit. Should outlive the completion report and the handoff. Update findings to ✅ in place as they are remediated; do not delete.

## Severity legend

- 🔴 **Critical** — needs action this week. Security/IP exposure or blocking risk.
- 🟠 **High** — needs action this month. Material security or operational risk.
- 🟡 **Medium** — should be addressed before public launch.
- 🟢 **Low** — polish, hygiene.

---

## 1. Findings summary

| # | Severity | Title | Status |
|---|---|---|---|
| 1 | 🔴 Critical | Formula IP exposed in tracked files | ⬜ Open |
| 2 | 🔴 Critical | `.gitignore` UTF-16 encoding bug | ⬜ Open |
| 3 | 🔴 Critical | Strava OAuth `state` is not a CSRF token | ⬜ Open |
| 4 | 🟠 High | Missing security headers (CSP, HSTS, Permissions-Policy) | ⬜ Open |
| 5 | 🟠 High | Working-tree drift — 24 modified, uncommitted files | ⬜ Open |
| 6 | 🟠 High | No production observability (Sentry / UptimeRobot / Analytics) | ⬜ Open |
| 7 | 🟠 High | No rate limiting on public endpoints | ⬜ Open |
| 8 | 🟡 Medium | PostgREST URL interpolation without `encodeURIComponent` | ⬜ Open |
| 9 | 🟡 Medium | Wide `innerHTML` usage (39 sites) without CSP | ⬜ Open |
| 10 | 🟡 Medium | `dev` branch still exists despite main-only workflow | ⬜ Open |

---

## 2. Findings detail

### 1. Formula IP exposed in tracked files (Critical)

**Scope:** Six files at repo root, 633 lines total.

**Files:**
- `vercel-paste-ready.txt` (153 lines)
- `HANDOVER-RPS-ENV-VARS.md` (254 lines)
- `vercel-env-template.txt` (102 lines)
- `set-env-vars.ps1` (74 lines)
- `RMM_Route_Analyzer_Env_Vars.xlsx` (34 rows)
- `vercel-dds-env-vars.txt` (16 lines)

**Why it matters:** All 93+ formula env vars including the full `BASE_CLASS_MATRIX` JSON are present in plaintext. Violates [[core_principles]] ("All formula values in env vars only — never in code, comments, or variable names") and [[ip_protection]] ("Reasonable steps to maintain secrecy must be demonstrable"). Repo remote is `github.com/ValkenMadness/runmadmaps.git`. If repo is or was ever public, world-readable.

**Fix:** See [[ip_protection]] "Remediation status" section. Sequence: confirm visibility → `git rm` → `.gitignore` → `git filter-repo` to scrub history → force-push. ~90 min.

**Cross-link:** [[master_task_list]] NEW-46 · [[launch_readiness_checklist]] #52

---

### 2. `.gitignore` UTF-16 encoding bug (Critical)

**Scope:** `.gitignore`, `api/python/__pycache__/`

**Why it matters:** Last line of `.gitignore` is UTF-16-encoded (PowerShell save artifact). Git reads `.gitignore` as UTF-8 — rule does not match. Six `.pyc` files currently tracked. Every Python edit adds new `.pyc` files to the tracked set, so the leak grows with each commit.

**Tracked files (as of 2026-05-22):**
- `api/python/__pycache__/_config.cpython-310.pyc`
- `api/python/__pycache__/_descent_grader.cpython-310.pyc`
- `api/python/__pycache__/_gps_processor.cpython-310.pyc`
- `api/python/__pycache__/_supabase.cpython-310.pyc`
- `api/python/__pycache__/trails.cpython-310.pyc`
- `api/python/__pycache__/upload.cpython-310.pyc`

**Why subtle:** File looks correct in an editor. `xxd` reveals null bytes interleaving every character of the bottom rule (`0061 0070 0069 002f` = `a.p.i./`).

**Fix:** Re-save `.gitignore` as UTF-8 / no BOM / LF endings. `git rm -r --cached api/python/__pycache__`. Commit. ~15 min.

**Cross-link:** [[master_task_list]] NEW-47 · [[launch_readiness_checklist]] #59

---

### 3. Strava OAuth `state` is not a CSRF token (Critical)

**Scope:** `api/auth/strava-login.js`, `api/auth/strava-callback.js`.

**Why it matters:** `state` is meant to be an unguessable nonce that binds the consent redirect to the user who started it. Current code uses it to carry the post-auth `return_to` URL only — no nonce, no signed cookie, no callback verification. Account-linking CSRF: an attacker can cause a victim's RMM account to be linked to the attacker's Strava identity.

**Exploit:** Full step-by-step in [[oauth_and_api_compliance]] under "OAuth state parameter as CSRF protection". 6 steps from attacker-captured `code` to victim's account having attacker's Strava activities polluting their RPS.

**Fix:** Generate random nonce (`crypto.randomBytes(32).toString('hex')`), compute `state = HMAC(secret, nonce + return_to)`, store in signed `HttpOnly+Secure+SameSite=Lax` cookie, verify on callback in constant time, clear cookie after use. ~30 min.

**Cross-link:** [[master_task_list]] NEW-48 · [[launch_readiness_checklist]] #58 · [[oauth_and_api_compliance]]

---

### 4. Missing security headers (High)

**Scope:** `vercel.json` `headers` array.

**Currently set:** `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin`.

**Missing:**
- `Content-Security-Policy` — essential given 39 `innerHTML` sites and 9 inline `<script>` blocks.
- `Strict-Transport-Security` — Vercel may set by default but should be asserted.
- `Permissions-Policy` — should explicitly deny geolocation, microphone, camera since none are used.

**Suggested CSP baseline:** `default-src 'self'; script-src 'self' https://api.mapbox.com 'unsafe-inline'; style-src 'self' https://fonts.googleapis.com https://api.mapbox.com 'unsafe-inline'; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https://*.supabase.co https://api.mapbox.com https://www.strava.com`. Tighten `'unsafe-inline'` in a later pass once inline scripts are removed.

**Fix:** Add the three headers to `vercel.json`. ~30 min.

**Cross-link:** [[master_task_list]] NEW-49 · [[launch_readiness_checklist]] #57

---

### 5. Working-tree drift (High, transient)

**Scope:** 24 files modified locally, not committed.

**Surface:** 5 auth files (`account.js`, `session.js`, `strava-callback.js`, `strava-activities.js`, `auth.js`), 6 Python engines (`_anti_gaming.py`, `_dem_lookup.py`, `_race_readiness.py`, `_route_grader.py`, `_rps_engine.py`, `_supabase.py`), 6 HTML pages (dashboard, profile, signin, signup, three intelligence pages), 2 SQL migrations, `vercel-paste-ready.txt`, `RMM_State_of_the_Build_2026-05-07.md`, `.claude/settings.local.json`.

**Why it matters:** Local production ≠ deployed production. Brain status notes track deployed state, so any uncommitted work isn't reflected. Laptop loss = work loss.

**Fix:** For each file: `git diff` → commit (with message) → push, or `git checkout --` to discard. ~30–60 min review.

**Cross-link:** [[master_task_list]] NEW-50 · [[launch_readiness_checklist]] #60

---

### 6. No production observability (High)

**Scope:** Whole platform.

**Why it matters:** No Sentry, no UptimeRobot, no Vercel Analytics, no structured logging. Every other risk on this list has a longer detection time without these.

**Fix:**
- Sentry (free tier) — errors + stack traces. ~30 min wiring.
- UptimeRobot (free tier) — 5-minute ping, alerts via email/SMS.
- Vercel Analytics — included; page views, route popularity, deploy/error correlation.

~2 hr total.

**Cross-link:** [[master_task_list]] NEW-51, #160, #161, #162 · [[launch_readiness_checklist]] #13, #44, #61

---

### 7. No rate limiting on public endpoints (High)

**Scope:** `/api/subscribe`, `/api/python/upload` (public analyze mode, no `athlete_id`), `/api/auth/strava-login`.

**Why it matters:** Subscribe can be brute-forced for email validity. Public analyze accepts arbitrary GPX uploads — no size cap, no per-IP cap, can chew Vercel invocation seconds. Strava-login can be abused to redirect-spam Strava.

**Fix:** Vercel edge middleware with IP-keyed token bucket, or table-level check + IP hash + window. Add request size cap on `/api/python/upload`. ~1 hr.

**Cross-link:** [[master_task_list]] NEW-52 · [[launch_readiness_checklist]] #50, #62

---

### 8. PostgREST URL interpolation without `encodeURIComponent` (Medium)

**Scope:** 6 files. `session_token=eq.${sessionToken}` pattern used directly:
- `api/auth/account.js`
- `api/auth/logout.js`
- `api/auth/session.js`
- `api/auth/strava-activities.js`
- `api/auth/strava-callback.js`
- `api/python/trails.py`

**Why it matters:** Not exploitable today (token is `crypto.randomUUID()` — no special characters). Fragile because: (a) a future token format containing `&` would break the query, (b) a future field interpolated similarly with user input could be exploitable. The pattern in `api/auth/account.js:75` (`email=eq.` + `encodeURIComponent(email)`) is correct — copy it everywhere.

**Fix:** Wrap every `session_token` interpolation in `encodeURIComponent()`. ~30 min.

**Cross-link:** [[master_task_list]] NEW-53 · [[launch_readiness_checklist]] #63

---

### 9. Wide `innerHTML` usage without CSP (Medium)

**Scope:** 39 `innerHTML =` sites across `scripts/*.js`. Most build markup from controlled string literals or category lookups. Highest-risk:

- `scripts/poi-manager.js:296` — table rows from `poi.name`, `poi.description`, `poi.category`, `poi.status`. Admin-only, but a second admin could XSS the founder.
- `scripts/trail-library.js` — segment editor with similar pattern.

**Why it matters:** Combined with finding #4 (no CSP), the XSS blast radius is wider than it needs to be even with admin-only surfaces.

**Fix:** (a) Add CSP per finding #4. (b) HTML-escape helper applied to every user-controlled value before string concatenation. (c) Move inline `onclick="..."` handlers (a few in `map.js` POI detail popups) to `addEventListener`. ~1 hr for the escape helper pass.

**Cross-link:** Not separately tracked in master_task_list (rolled into NEW-49 CSP work). Could be a NEW item if escape helper is treated as a separate concern.

---

### 10. `dev` branch still exists despite main-only workflow (Medium)

**Scope:** Local + `origin/dev`.

**Why it matters:** [[release_workflow]] (updated 2026-05-12) explicitly says everything pushes to `main` and `dev` is deprecated. The lingering branch creates confusion for any AI session that picks the wrong base. Cosmetic but ~5 min to fix.

**Fix:** `git branch -d dev` locally, `git push origin --delete dev`. ~5 min.

**Cross-link:** [[master_task_list]] NEW-55

---

## 3. Pre-launch security checklist (extracted)

This is the minimum security posture before opening the platform to a wider public. All ten items above should be ✅ before any public marketing push.

**Critical (this week):**
- [ ] Confirm GitHub repo visibility
- [ ] Remove formula IP from git history (finding 1)
- [ ] Fix `.gitignore` + untrack `__pycache__` (finding 2)
- [ ] Patch Strava OAuth `state` CSRF (finding 3)

**High (this month):**
- [ ] Add CSP + HSTS + Permissions-Policy (finding 4)
- [ ] Commit-or-discard working tree (finding 5)
- [ ] Add Sentry + UptimeRobot + Vercel Analytics (finding 6)
- [ ] Add rate limiting on public endpoints (finding 7)
- [ ] `encodeURIComponent` every `session_token` interpolation (finding 8)

**Medium (pre-launch):**
- [ ] HTML-escape helper for admin `innerHTML` (finding 9)
- [ ] Delete `dev` branch (finding 10)

## 4. Strengths (preserve)

The audit also confirmed these are working well — protect them:

- No real secrets in tracked source files (verified by `grep` across all extensions).
- `_LazyDescriptor` config pattern in `api/python/_config.py` — no formula values leak into Python source as defaults.
- `crypto.scryptSync` password hashing with random salt — no npm crypto dep.
- Service role key used only in serverless functions; anon key (new `sb_publishable_` format) only in client JS.
- `RMM_PLATFORM_VERSION` session-version gate — clean way to force global re-login on terms changes.
- Dual-table logout closes the gap where `athletes`-side sessions could be re-used.
- CORS lockdown on `/api/config` restricts origins to `runmadmaps.com` + `localhost:3000`.

## How to use this document

- Treat as the canonical security reference until a future audit replaces it.
- When a finding is remediated, flip its status in the summary table and add a "Resolved YYYY-MM-DD" line in the detail section. Do not delete.
- New security findings discovered between audits should be added here with a new finding number, not just to the master task list.
- The pre-launch checklist (Section 3) is the gate. Don't open the doors wider until those items are checked.
