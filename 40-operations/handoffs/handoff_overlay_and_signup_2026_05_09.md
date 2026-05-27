---
title: handoff_overlay_and_signup_2026_05_09
domain: rmm
type: handoff
status: active
created: 2026-05-09T00:00:00.000Z
updated: 2026-05-09T00:00:00.000Z
updated_by: claude_cowork
tags: [handoff, overlay, signup, mailing-list, auth]
supersedes: ""
related: ["[[handoff_auth_system_2026_05_08]]", "[[website_component_map]]", "[[website_data_flow]]", "[[website_architecture]]"]
---

# Handoff — Overlay Swap & Signup Auto-Subscribe (2026-05-09)

## What Was Done

Three connected changes to unify the mailing list and platform signup flows, plus a CSS fix.

### 1. Replaced Mailing List Lightbox with "Create Free Account" Lightbox

**File:** `scripts/map.js` — `initEmailOverlay()` function rewritten.

The old overlay collected name + email + consent and posted to `/api/subscribe`. It has been replaced with a simpler "Create Free Account" prompt.

**Current state (Coming Soon mode):**
- Eyebrow: "Free Account"
- Headline: "Get your race number. Join the community."
- Body: explains what the free account unlocks
- CTA button: "Coming Soon" — `disabled` attribute, unclickable
- Dismiss button: "No thanks, just the map" — unchanged behaviour

**To go live:** Set `RMM_OVERLAY_LIVE = true` at the top of map.js (near line 1621). This switches the CTA to an `<a href="/signup">` styled as a button reading "Create Free Account".

**Suppression logic (expanded):**
- `localStorage.rmm_subscribed === 'true'` — unchanged
- NEW: `document.cookie.indexOf('rmm_session') !== -1` — logged-in users never see the overlay

**Removed code:** `handleOverlaySubmit()` function deleted — no longer needed since the overlay no longer collects form data.

### 2. Auto-Add Platform Signups to Mailing List

**File:** `api/auth/account.js` — `handleSignup()` function.

After successfully creating a user record in the `users` table, the endpoint now also inserts into the `subscribers` table:

```javascript
{
  email: email,
  first_name: firstName,
  consent_given: true,
  source: 'platform-signup'
}
```

- Duplicate emails (409 from Supabase unique constraint) are silently ignored — the user may have subscribed via the old mailing list before creating an account.
- Failure of the subscriber insert does NOT fail the signup — it's wrapped in a try/catch that logs and continues.
- The `source` value `'platform-signup'` distinguishes these from older `'map-overlay'` or `'landing_page'` subscribers.

### 3. localStorage Flag on Signup Success

**File:** `pages/signup.html` — inline `<script>`.

After a successful signup response, `localStorage.setItem('rmm_subscribed', 'true')` is now called immediately (before showing the race number reveal). This ensures the map overlay won't appear for this user even if their session cookie expires.

### 4. Fixed Button Overflow on Race Number Card

**File:** `styles/pages.css`

The "Go to Profile" and "View Dashboard" buttons on the signup success card were overflowing the right edge of the white card container. Root cause: `.auth-submit` had `width: 100%` with `padding: 0.85rem 1.5rem` but no `box-sizing: border-box`, so the padding added to the total width.

**Fix:** Added `box-sizing: border-box` to `.auth-submit` and `.auth-input` rules. Also added `width: 100%` to `.auth-input` for consistency.

### 5. Overlay CSS Addition

**File:** `styles/map.css`

Added `.rmm-overlay-cta-link` class for the live-mode `<a>` element styled as a button (text-decoration, display, text-align, box-sizing).

## Files Modified

| File | Change |
|---|---|
| `scripts/map.js` | Rewrote `initEmailOverlay()`, removed `handleOverlaySubmit()`, added `RMM_OVERLAY_LIVE` flag, added session cookie suppression check |
| `api/auth/account.js` | Added subscriber auto-insert after successful signup in `handleSignup()` |
| `pages/signup.html` | Added `localStorage.rmm_subscribed = 'true'` on signup success |
| `styles/pages.css` | Added `box-sizing: border-box` to `.auth-submit` and `.auth-input` |
| `styles/map.css` | Added `.rmm-overlay-cta-link` class |

## What's NOT Changed

- `/api/subscribe.js` — untouched, still works for any future direct subscription use
- `subscribers` Supabase table schema — no migration needed
- Strava OAuth flow — untouched
- All other pages — untouched
- Map functionality — untouched

## Design Decisions

- **Flag-based activation** rather than code swap: `RMM_OVERLAY_LIVE` is a single boolean at the top of `map.js`. Changing it flips the overlay from "Coming Soon" to live signup CTA. No other code changes needed.
- **Non-blocking subscriber insert**: The mailing list auto-add happens fire-and-forget after user creation. A failed subscriber insert never blocks or fails the signup flow.
- **Dual suppression**: Both `localStorage` and session cookie are checked. localStorage provides persistence across sessions (even after logout). The cookie check catches logged-in users who somehow cleared localStorage.

## Next Steps

- Go live: Set `RMM_OVERLAY_LIVE = true` when ready for public signups
- Post-signup welcome email flow (noted as future requirement — not built yet)
- Consider Vercel Pro upgrade to split `account.js` back into separate endpoints
