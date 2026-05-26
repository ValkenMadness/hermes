---
title: oauth_and_api_compliance
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-22
updated_by: claude_cowork
tags: [legal, oauth, api-compliance, strava, security]
supersedes: ""
related: ["[[popia_compliance]]", "[[ip_protection]]", "[[data_architecture]]", "[[security_audit_findings_2026_05_22]]", "[[completion_report_audit_2026_05_22]]"]
---

**Strava:** Read API Agreement before launch. Attribution requirements, rate limiting, data usage restrictions, user consent requirements.

**Garmin:** Separate developer agreement. Apply for API access well before launch — approval can take weeks.

## OAuth state parameter as CSRF protection (added 2026-05-22)

The OAuth 2.0 `state` parameter is a CSRF-protection primitive, not a general-purpose carrier for application data. It must be:

1. **Random and unguessable** per login attempt (>=128 bits of entropy from a cryptographic RNG).
2. **Bound to the user's session** via a server-side store or signed cookie, so the callback can verify the same browser that initiated the login is completing it.
3. **Verified on callback** before any account-creation or account-linking operation. If `state` is absent, malformed, or doesn't match the stored value, the callback must reject the request.
4. **Single-use** — invalidated as soon as it's been verified, so a captured callback URL cannot be replayed.

### Current RMM implementation status

As of the 2026-05-22 audit, RMM's `state` usage **does not meet any** of the four requirements above. `api/auth/strava-login.js` passes the user's `return_to` URL into `state`. `api/auth/strava-callback.js` decodes `state` for redirect purposes but performs no verification.

Concrete exploit (account-linking CSRF):

1. Attacker authorises Strava with their own account, captures the resulting `code` from the redirect URL.
2. Attacker crafts a link to `/api/auth/strava-callback?code=ATTACKER_CODE&state=/profile`.
3. Victim (already logged into RMM via email/password) clicks the link.
4. Callback upserts the attacker's Strava athlete record into the `athletes` table.
5. Callback reads the victim's `rmm_session` cookie, finds the victim's user, and writes `strava_athlete_id = ATTACKER_STRAVA_ID` and `strava_connected = true` onto the victim's `users` row.
6. Victim's RMM account is now linked to the attacker's Strava — RPS calculations are polluted by the attacker's activities, support tickets, identity confusion.

### Required fix

Tracked as [[master_task_list]] NEW-48 and [[launch_readiness_checklist]] #58.

Minimum implementation:

- At login: generate a random nonce (`crypto.randomBytes(32).toString('hex')`), compute `state = HMAC(secret, nonce + return_to)`, set a signed `rmm_oauth_nonce` cookie (HttpOnly, Secure, SameSite=Lax, short Max-Age e.g. 10 min).
- At callback: read the cookie, recompute the expected HMAC, compare in constant time. On mismatch or missing cookie, redirect to `/signin?error=oauth_state` without touching the database.
- Clear the cookie on successful or failed verification (single-use).

~30 minutes of implementation. Strava's own OAuth documentation describes the `state` parameter's CSRF role explicitly.

### Other OAuth-adjacent hardening logged 2026-05-22

- **Rate limit `/api/auth/strava-login`** — currently unrated. ([[master_task_list]] NEW-52, [[launch_readiness_checklist]] #62.)
- **Strava deauthorisation handler** — required by Strava API terms. ([[master_task_list]] #146.)
- **PostgREST URL hygiene** — `session_token` is interpolated into REST URLs without `encodeURIComponent` in 6 files including `strava-callback.js` and `strava-activities.js`. Not exploitable today (token is `randomUUID()`) but fragile. ([[master_task_list]] NEW-53, [[launch_readiness_checklist]] #63.)
