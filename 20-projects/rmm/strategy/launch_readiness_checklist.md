---
title: launch_readiness_checklist
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-27
updated_by: claude_cowork
tags: [strategy, launch, checklist]
retrieval_priority: high
supersedes: ""
related: ["[[phased_build_plan]]", "[[website_build_status_overview]]", "[[website_build_status_issues]]", "[[master_task_list]]", "[[handoff_rps_golive_2026_05_06]]", "[[completion_report_audit_2026_05_22]]", "[[security_audit_findings_2026_05_22]]", "[[ip_protection]]"]
---

**As of: 2026-05-22** — updated after the 2026-05-22 read-only audit. Status flips applied, item #52 expanded with full IP remediation sequence, and 8 new items (#57–#64) added covering security headers, OAuth CSRF, gitignore bug, working-tree drift, observability, rate limiting, URL hygiene, and OG image. See [[completion_report_audit_2026_05_22]] and [[security_audit_findings_2026_05_22]].

Status legend: ✅ Done · 🔄 In progress / partial · ⬜ Not started · ⏸ Deferred · 🟡 Wired but not data-complete

---

### Product & Engineering

| # | Item | Status | Notes |
|---|------|--------|-------|
| 1 | Platform deployed on Vercel with custom domain | ✅ Done | Live at runmadmaps.com (+ .co.za redirect) since April. Auto-deploy on push to main. |
| 2 | Strava OAuth integration working | ✅ Done | Login, callback, session, logout, auto-refresh all live (2026-05-03). Client ID 163342. |
| 2b | Email/password auth system | ✅ Done | Full signup/signin/profile/signout flow live (2026-05-08). `users` table with scrypt-hashed passwords. Race numbers auto-generated. Admin role system. Three-state page gating across intelligence/dashboard. Consolidated into `account.js` for Vercel Hobby limit. Signup auto-subscribes to mailing list (2026-05-09). Map overlay swapped to "Create Free Account" prompt (CTA disabled as "Coming Soon" — set `RMM_OVERLAY_LIVE = true` in map.js to activate). |
| 3 | Strava webhook subscription registered and validated | ⬜ Not started | Sync currently triggered manually via `POST /api/auth/strava-activities`. |
| 4 | GPS Stream Processor in production | ✅ Done | `api/python/gps_processor.py` ported and live since 2026-04-25. |
| 5 | Route Grading V3 implemented | ✅ Done | `api/python/route_grader.py` + public Route Analyzer at `/intelligence/routes`. |
| 6 | RPS Engine implemented | ✅ Done | `api/python/rps_engine.py` live; first real score 28/Active computed 2026-05-06. |
| 7 | Anti-gaming F1–F10 running on ingest | ✅ Done | `api/python/anti_gaming.py` deployed; runs during authed uploads. |
| 8 | Route library with 20–30 routes graded and described | 🔄 ~7 graded, 0 described | 7 real GeoJSON routes loaded; `Silvermine-Lower-Route-1.geojson` is empty placeholder. No descriptions. |
| 9 | Interactive route map with grade overlay | ✅ Done | Grade-coloured route lines via `match` expression added 2026-04-30. |
| 10 | Athlete dashboard (RPS, breakdown, trends) | 🔄 Partial | Dashboard layout built, map panel works. RPS / Readiness / Lifetime / Peak Hunter / Cave Diver panels are header divs with empty bodies. Fitness page itself is fully wired. Auth-gated: requires login + Strava connection to see live data. |
| 11 | Admin dashboard | ⬜ Not started | `modules/` is `.gitkeep` only. Spec G8 not signed off. |
| 12 | Database backup system operational | ⬜ Not started | Master task list #144. |
| 13 | Error tracking and uptime monitoring | ⬜ Not started | Sentry (#160), UptimeRobot (#161), Vercel Analytics (#162) all pending. |
| 14 | Benchmark ceilings calibrated against real data | 🔄 In progress | V + Nathan sourcing GPX. Open question ST3-1. |
| 15 | Basic integration tests for GPS pipeline | ⬜ Not started | Master task list #147. |
| 16 | Race Readiness wired end-to-end | 🟡 Wired | Backend + frontend connected with dynamic route selector (2026-05-06). Untestable until at least one graded GPX is uploaded while logged in. |
| 17 | Activity sync working | ✅ Done | 27 activities synced 2026-05-06 after UUID→TEXT migration. |
| 18 | Supabase production schema | ✅ Done | `subscribers`, `athletes`, `activities`, `rps_scores`, `rps_history`, `route_analyses`, `style_config` all live with RLS. |
| 19 | Map cluster + popup + filter system | ✅ Done | Cluster fan-out refined to brief 2026-04-30; smart popup anchor; filter sidebar 2026-04-27. |
| 20 | Map intro animation / cinematic flyover | ⬜ Not started | Map Stage 4 outstanding. |

### Legal & Compliance

| # | Item | Status | Notes |
|---|------|--------|-------|
| 21 | Privacy Policy published (POPIA) | ✅ Drafted, live | At `/privacy`. Carries draft notice. Effective date 10 April 2026. |
| 22 | Terms of Service published | ✅ Drafted, live | At `/terms`. Carries draft notice. |
| 23 | Cookie Policy | ✅ Drafted, live | At `/cookies`. Carries draft notice. |
| 24 | Acceptable Use Policy | ✅ Drafted, live | At `/acceptable-use`. NEW addition. |
| 25 | Legal index page | ✅ Done | At `/legal`. NEW addition. |
| 26 | Authorship record timestamped | ✅ Done | V as sole author, all systems documented. |
| 27 | Strava API terms reviewed | ⬜ Not started | Master task list #20. |
| 28 | Garmin API access applied for | ⬜ Not started | Master task list #21. Long lead time. |
| 29 | Attorney review of all 4 legal documents | ⬜ Not started | NEW-24. Blocks lifting draft notices. |
| 30 | Data deletion capability (POPIA right to be forgotten) | ⬜ Not started | Master task list #159. Described in Privacy Policy as 30-day hard purge. |
| 31 | Trademark registration (CIPC) | ⏸ Deferred | Capital not available. ~R1,180 for Classes 42+41. |
| 32 | Cookie consent banner UI | ⬜ Not started | Cookie Policy exists; no consent management UI. |

### Content & Community

| # | Item | Status | Notes |
|---|------|--------|-------|
| 33 | Route description template finalised | ⬜ Not started | Master task list #195. |
| 34 | 20–30 route descriptions written | ⬜ Not started | Master task list #197. |
| 35 | Run 20–30 core Peninsula routes with GPS | ⬜ Not started | V's job. Master task list #196. |
| 36 | Route photography on training runs | ⬜ Not started | Recurring task #268. |
| 37 | FAQ page | ⬜ Not started | Master task list #158. |
| 38 | Instagram account with 5–10 launch posts | ⬜ Not started | Master task list #199 + #201. |
| 39 | Strava Club created | ⬜ Not started | Master task list #200. |
| 40 | Brand voice guidelines documented | ✅ Done | Phase 0 #12. In Brain at `rmm/overview/voice.md`. |
| 41 | First month content calendar | ⬜ Not started | Master task list #202. |
| 42 | OG image for social sharing | ⬜ Not started | Bug 2 — `og-image.png` referenced in meta tags but file does not exist. |

### Operations

| # | Item | Status | Notes |
|---|------|--------|-------|
| 43 | Cost tracking spreadsheet | ✅ Done | Phase 0 #30. |
| 44 | Monitoring alerts configured | ⬜ Not started | Master task list #163. |
| 45 | Daily score recalculation cron job | ⬜ Not started | Master task list #145. Endpoint exists (`/api/python/recalculate-decay`); nothing calls it. |
| 46 | Strava deauthorisation handler | ⬜ Not started | Master task list #146. |
| 47 | Email delivery configured (Resend) | ⬜ Not started | Master task list #170. Needed for post-signup welcome emails. |
| 48 | Onboarding email sequence implemented | ⬜ Not started | Master task list #172. Signup auto-subscribes to mailing list (2026-05-09), but no emails send yet — needs transactional email service. |
| 49 | Support email configured | ⬜ Not started | Master task list #32. |
| 50 | Rate limiting on public endpoints | ⬜ Not started | Subscribe / Analyze / Strava-login currently unrated. |

### Security & Repo Hygiene

| # | Item | Status | Notes |
|---|------|--------|-------|
| 51 | Secrets out of git | ✅ Done | `.env`, `.env.local`, `.env.production` all properly gitignored. No hardcoded secrets in tracked source. |
| 52 | Formula IP out of git | ⬜ **NOT DONE — escalated 2026-05-22** | Six tracked files at repo root expose all 93+ formula env vars: `vercel-paste-ready.txt` (153 lines), `HANDOVER-RPS-ENV-VARS.md` (254 lines), `vercel-env-template.txt` (102 lines), `set-env-vars.ps1` (74 lines), `RMM_Route_Analyzer_Env_Vars.xlsx` (34 rows), `vercel-dds-env-vars.txt` (16 lines) = 633 lines total. Violates own `.env.example` rule + [[core_principles]] + [[ip_protection]]. Remediation: (1) confirm GitHub repo visibility, (2) `git rm` all six, (3) add to `.gitignore`, (4) `git filter-repo` to scrub history, (5) force-push, (6) rotate any co-leaked secrets (none observed). ~90 min. **Critical.** Cross-link [[master_task_list]] NEW-46 and [[security_audit_findings_2026_05_22]]. |
| 53 | Security headers in vercel.json | 🔄 Partial | `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin` set. **Missing 2026-05-22**: `Content-Security-Policy`, `Strict-Transport-Security`, `Permissions-Policy`. Wide XSS blast radius with 39 `innerHTML` sites + 9 inline `<script>` blocks. See #57 below. |
| 54 | CORS restricted on /api/config | ✅ Done | Only `runmadmaps.com` and `localhost:3000`. |
| 55 | Strava client secret server-side only | ✅ Done | Read from `process.env.strava_oauth_client_secret`; never reaches client. |
| 56 | OAuth tokens stored with RLS | ✅ Done | `athletes` table RLS enabled; all access via service role from serverless. |
| 57 | Content-Security-Policy header | ⬜ Not started | Missing from `vercel.json`. With 39 `innerHTML` sites and 9 inline `<script>` blocks, XSS blast radius is wide. Suggested baseline: `default-src 'self'; script-src 'self' https://api.mapbox.com 'unsafe-inline'; style-src 'self' https://fonts.googleapis.com https://api.mapbox.com 'unsafe-inline'; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https://*.supabase.co https://api.mapbox.com https://www.strava.com`. ~30 min. **High.** See [[master_task_list]] NEW-49. |
| 58 | Strava OAuth `state` as CSRF token | ⬜ Not started | `api/auth/strava-login.js` puts `return_to` URL into `state`; `api/auth/strava-callback.js` decodes without verification. Account-linking CSRF risk — attacker captures Strava `code`, sends crafted callback link to logged-in RMM user, user's RMM identity gets linked to attacker's Strava. Fix: nonce + HMAC + signed cookie + callback verification. ~30 min. **Critical.** See [[master_task_list]] NEW-48 + [[security_audit_findings_2026_05_22]]. |
| 59 | `.gitignore` UTF-16 encoding bug | ⬜ Not started | Last line of `.gitignore` is UTF-16-encoded (typed in PowerShell, saved with wrong encoding). Git reads `.gitignore` as UTF-8 — rule does not match. Six `.pyc` files currently tracked in `api/python/__pycache__/`. Fix: re-save as UTF-8/LF, `git rm -r --cached api/python/__pycache__`. ~15 min. **Critical.** See [[master_task_list]] NEW-47. |
| 60 | Working-tree drift (transient) | ⬜ Not started (as of 2026-05-22) | 24 files modified locally not committed: 5 auth files, 6 Python engines, 6 HTML pages, 2 SQL migrations, `vercel-paste-ready.txt`, `RMM_State_of_the_Build_2026-05-07.md`, `.claude/settings.local.json`. Local production does not match deployed production. ~30–60 min review. **High.** See [[master_task_list]] NEW-50. |
| 61 | Observability stack | ⬜ Not started | No Sentry, no UptimeRobot, no Vercel Analytics, no structured logging. Cross-link master_task_list #160, #161, #162. ~2 hr. **High.** See [[master_task_list]] NEW-51. |
| 62 | Rate limiting on public endpoints | ⬜ Not started | `/api/subscribe`, `/api/python/analyze` (public mode), `/api/auth/strava-login` all unrated. ~1 hr. **High.** Duplicates #50; cross-link [[master_task_list]] NEW-52. |
| 63 | PostgREST URL-encoding hygiene | ⬜ Not started | `session_token` cookie value interpolated directly into REST URLs in 6 files (`account.js`, `logout.js`, `session.js`, `strava-activities.js`, `strava-callback.js`, `trails.py`) without `encodeURIComponent`. Not exploitable today (token is `randomUUID()`) but fragile. Pattern already correct in `account.js:75` for email. ~30 min. **High** (hygiene). See [[master_task_list]] NEW-53. |
| 64 | OG image asset | ⬜ Not started | `og-image.png` referenced in 5 `<meta>` tags; file does not exist in `/public/images/`. Social shares render without preview image. ~10 min (design + place). **Low** but visible. Tracked as Bug 2 in [[website_build_status_issues]] and as NEW-19 / NEW-64 in master_task_list. |

---

## Drift fixed in this update (2026-05-22)

The 2026-05-22 read-only audit pass flipped six items to ✅ that had been stale (#25, #44, #117, #126, #132, #150 in [[master_task_list]]). Item #52 (Formula IP out of git) was expanded from referencing 3 files to the actual 6 tracked files with full remediation sequence. Item #53 (Security headers) was reclassified from ✅ to 🔄 because three important headers are missing. Eight new items (#57–#64) were added covering audit findings. See [[completion_report_audit_2026_05_22]].

---

## Drift fixed in this update (2026-05-07)

The previous version of this checklist (last updated 2026-04-23) showed all engines as "Formula Lab only", all legal docs as "Not started", platform deployment as "Not started". All of these were materially out of date. This rewrite reflects the actual state of the codebase as of 2026-05-07. See [[handoff_state_of_build_2026_05_07]] for the full audit report.
