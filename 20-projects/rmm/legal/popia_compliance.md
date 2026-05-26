---
title: popia_compliance
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [legal, popia, compliance]
supersedes: ""
related: ["[[ip_protection]]", "[[oauth_and_api_compliance]]", "[[data_architecture]]"]
---

POPIA (Protection of Personal Information Act) is South African data protection law. Not optional.

### What RMM Collects

| Data | Purpose | Legal Basis |
|------|---------|------------|
| Email address | Account identification, communications | Consent at registration |
| Strava/Garmin profile | OAuth authentication, activity sync | Consent via OAuth flow |
| GPS activity data | RPS scoring, route grading, race readiness | Consent via OAuth scope |
| Heart rate data (if available) | Supplementary display (not scored) | Consent via OAuth scope |
| Device/browser info | Security, debugging | Legitimate interest |

### Required Documentation (Produce Before Launch)

1. **Privacy Policy:** What is collected, why, how processed, retention periods, athlete rights (access, correction, deletion), cross-border transfers.
2. **Terms of Service:** Account terms, acceptable use, liability, IP (formulas are trade secrets), data ownership (athletes own data, RMM has processing licence).
3. **Cookie Policy:** If using analytics cookies.

### Data Minimisation

Collect only what is needed. OAuth scopes: activity read, profile read. Do NOT request write access, social data, or unnecessary scopes.

### Deletion Rights

Athletes must be able to fully delete account and all data. Complete purge, not soft delete. Leaderboard entries anonymised rather than deleted. Active accounts retained while account exists. Deleted accounts purged within 30 days.

### Email Compliance

Explicit opt-in. Unsubscribe in every email. Separate consent for marketing vs transactional.
