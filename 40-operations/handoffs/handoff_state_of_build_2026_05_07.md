---
title: handoff_state_of_build_2026_05_07
domain: rmm
type: handoff
status: active
created: 2026-05-07
updated: 2026-05-07
updated_by: claude_opus_cowork
tags: [handoff, audit, milestone, state-of-build, security, brain-reconciliation]
supersedes: ""
related: ["[[handoff_rps_golive_2026_05_06]]", "[[website_build_status_overview]]", "[[website_build_status_issues]]", "[[website_architecture]]", "[[master_task_list]]", "[[launch_readiness_checklist]]"]
---
# Handoff — State of the Build Audit Pass (2026-05-07)

**Session type:** Comprehensive audit
**Trigger:** Valken requested a full pause-and-take-stock review after hitting the technical-build milestone.
**Scope:** Full repo audit + Obsidian Brain reconciliation + security/secrets check + tasks/roadmap review + comprehensive report.

---

## Deliverable

Full State of the Business & Build report saved at:

`outputs/RMM_State_of_the_Build_2026-05-07.md`

The report covers: executive summary, business position, technical state (functional / scaffolded / not started), security & secrets audit, tasks & roadmap by lens, Brain ↔ reality drift, critical recommendations (today / this week / before launch / strategic), and an honest summary. Two appendices: repo inventory and Brain inventory.

---

## What this audit changed in the Brain

**Updated:**
- [[launch_readiness_checklist]] — full rewrite. Previous version (2026-04-23) showed all engines as "Formula Lab only", legal docs as "Not started", platform as "Not started" — all materially out of date. New version reflects actual state and adds Security & Repo Hygiene section.
- [[master_task_list]] — patched with NEW-30 through NEW-41 covering Strava OAuth completion, Supabase production schema, RPS env vars, UUID→TEXT migration, cross-discipline bonus fix, dynamic route selector, first live RPS score, plus four open items (mapStravaType fix, dashboard wiring, formula files out of git, FK restoration).

**Created:**
- This handoff note.

**Deferred (not changed):**
- All `rmm/codebase/*` notes — found to be current and accurate as of 2026-05-06.
- `rmm/operations/operating_philosophy.md`, `rmm/strategy/phased_build_plan.md`, all `rmm/overview/*` — stable.

---

## Headline findings

**Technical milestone real:** Engine Build Sequence Phases 1–2 LIVE public, Phase 3 LIVE for authed athletes (first real score 28/Active from 27 Strava activities computed 2026-05-06), Phase 4 WIRED with dynamic route selector (untestable only because no graded routes exist yet — needs one authed GPX upload).

**Architecture clean:** Vanilla JS frontend, no build, no npm runtime deps, all formula values in env vars (per spec), all secrets properly gitignored, security headers set globally, CORS restricted, OAuth tokens stored with RLS.

**One material policy violation:** All 93 formula values are committed to git in plain text via three files — `vercel-paste-ready.txt`, `set-env-vars.ps1`, `RMM_Route_Analyzer_Env_Vars.xlsx`. The `.env.example` explicitly forbids this. Plus `HANDOVER-RPS-ENV-VARS.md` (untracked) carries the same values inline. Recommended fix is in the report — `git rm --cached` + `.gitignore` additions, ~5 minutes.

**Public surface narrow but solid:** Map / About / Route Analyzer / legal pages. Everything else (Shop, Dashboard, Intelligence sub-pages, Leaderboards, Event, Product) is behind `?admin=madmaps` or in some scaffolded state.

**Polish-and-launch phase ahead is bigger than the engine-deploy phase just finished** — thirty small things rather than three big ones. Most consequential single accuracy improvement: fix `mapStravaType()` so trail runs aren't scored against road benchmarks (23/27 of currently synced activities affected).

---

## Recommended next moves (from the report)

**Today (≤30 min):**
1. `git rm --cached` the three formula files + add to `.gitignore`. Commit + push.
2. Upload one GPX via `/intelligence/routes` while logged in to seed `route_analyses` and unlock end-to-end Race Readiness testing.

**This week:**
3. Wire the dashboard's RPS, Readiness, and Lifetime Summary panels (pattern proven on Fitness page).
4. Fix `mapStravaType()` misclassification.

**Before public launch:**
5. Attorney review of legal docs (NEW-24).
6. Sentry + UptimeRobot + Vercel Analytics.
7. Daily decay cron (the endpoint exists at `/api/python/recalculate-decay`, nothing calls it).
8. Cross-browser + mobile QA.
9. Rate-limit public endpoints.
10. Restore activity ↔ athlete relationship at DB level (or document the by-application-only convention).

---

## Repo state at audit time

Branch `main`, up to date with `origin/main`. Working tree clean except `.claude/settings.local.json` (whitespace-only diff) and untracked `HANDOVER-RPS-ENV-VARS.md`. Last commit: `81153fc fix: dynamic route selector for readiness + list mode on race-readiness endpoint`.

Vercel function count: 12/12 (Hobby plan ceiling). Adding a new endpoint requires consolidating two existing or upgrading the plan.

---

## Related

- [[handoff_rps_golive_2026_05_06]] — previous milestone (RPS go-live)
- [[handoff_engine_port_to_vercel]] — engine deployment + env var setup
- [[handoff_supabase_production_schema]] — original (UUID-typed) schema
- [[handoff_strava_oauth_complete]] — OAuth deployment
- [[website_build_status_overview]] — current functional status, page by page
- [[website_build_status_issues]] — fix history with root causes
- [[website_architecture]] — canonical tech stack reference
