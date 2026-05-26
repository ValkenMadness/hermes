---
title: ip_protection
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-22
updated_by: claude_cowork
tags: [legal, ip, trade-secrets]
supersedes: ""
related: ["[[popia_compliance]]", "[[oauth_and_api_compliance]]", "[[the_four_strategic_moats]]", "[[security_audit_findings_2026_05_22]]", "[[completion_report_audit_2026_05_22]]", "[[master_task_list]]", "[[launch_readiness_checklist]]"]
---

### Trade Secrets

All formula values, weights, benchmark ceilings, and thresholds are trade secrets under South African common law. Reasonable steps to maintain secrecy must be demonstrable.

**What has been done:**
- All values in environment variables, never in production code
- `.env` files gitignored
- GitHub repository contains structure only, no secrets *in source files*
- Formula discussions in private Claude Project

**What still needs to be done:**
- Create timestamped authorship record (V as sole author, date, systems invented)
- Consider trademark registration with CIPC (~R590)
- Review patentability of processing pipeline or grading methodology with IP attorney when budget allows

## Current exposure status (as of 2026-05-22)

The "no values in source files" claim above holds for `_config.py` and the engine code — those files contain only env var *names*, no defaults, and crash deliberately on missing values via `_LazyDescriptor`. The 2026-05-22 audit confirmed this with `grep` — no formula values are hardcoded as defaults in any tracked `.py` file.

**However**, six tracked helper files at the repo root contain the full set of formula values in plaintext:

| File | Lines | Contents |
|---|---|---|
| `vercel-paste-ready.txt` | 153 | All 93 formula env vars with values, including the full `BASE_CLASS_MATRIX` JSON |
| `HANDOVER-RPS-ENV-VARS.md` | 254 | RPS values + handover documentation |
| `vercel-env-template.txt` | 102 | Template populated with values (not blanks) |
| `set-env-vars.ps1` | 74 | PowerShell array containing the values |
| `RMM_Route_Analyzer_Env_Vars.xlsx` | 34 rows | Spreadsheet form of the values |
| `vercel-dds-env-vars.txt` | 16 | All 16 Descent Difficulty Score env vars with values |
| **Total** | **633 lines** | Every weight, threshold, benchmark, the full matrix |

These files are tracked on `main` and have been since at least 2026-05-07 (first logged then as `master_task_list` NEW-40 covering three of the six files). The repo remote is `https://github.com/ValkenMadness/runmadmaps.git`. If the repo is or has ever been public, these values are world-readable.

This **directly violates** the principle stated above ("All values in environment variables, never in production code"), [[core_principles]] ("All formula values in env vars only — never in code, comments, or variable names"), and the requirement that "reasonable steps to maintain secrecy must be demonstrable" — they are not demonstrable while these files are tracked.

### Remediation status

Tracked as [[master_task_list]] NEW-46 (Critical) and [[launch_readiness_checklist]] #52 (escalated 2026-05-22).

Removing the files from current HEAD is necessary but not sufficient — git history preserves them. Full remediation:

1. Confirm GitHub repo visibility (set private if not already).
2. `git rm` all six files locally.
3. Add the six filenames to `.gitignore`.
4. Use `git filter-repo` (or BFG Repo-Cleaner) to scrub them from history.
5. Force-push the cleaned history to `origin`.
6. Confirm no historical commit still carries them (`git log --all --source --remotes -p -- <file>`).
7. Rotate any credentials that may have leaked alongside (none observed in the 2026-05-22 audit — only IP, not credentials).
8. Update this document and [[launch_readiness_checklist]] #52 when complete.

~90 minutes including history rewrite.

### Why ongoing brain-update discipline matters here

This issue was first surfaced 2026-05-07. The remediation never happened. The 2026-05-22 audit re-surfaced it and expanded the scope (3 files to 6 files). The lesson: IP-exposure issues should not sit on a task list as a checkbox alongside dozens of feature tasks. They warrant their own escalation path — either a recurring weekly check in [[brain_health_checklist]], or a status flag on this document that's visible in every brain audit.

Suggested ongoing check: add to [[brain_health_checklist]] a line "Confirm `git ls-files` returns zero formula-value files at repo root" under a new "IP Hygiene" section.
