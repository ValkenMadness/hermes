---
title: financial_tracking_and_cost_monitoring
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [finance, tracking, costs]
supersedes: ""
related: ["[[revenue_streams]]", "[[device_strategy]]"]
---

### Pre-Revenue Phase

Track three numbers monthly: total costs, total hours V spent on RMM, cash runway remaining. Tool: a simple spreadsheet with 12 columns.

**Cost categories:** Claude Pro subscription, Vercel hosting, Google Maps Elevation API, domain/DNS, email delivery, Strava API, GitHub, miscellaneous.

**When subscriptions launch:** Move to Xero or FreshBooks for VAT, invoicing, and financial reporting.

### Cost Monitoring

API usage is the primary variable cost. Billing alerts on every service:
- Google Cloud: alert at R500/month, hard cap at R1,000/month
- Vercel: alert at 80% of free tier, then at R500/month
- Resend: alert at 80% of free tier

Monthly cost review on the 1st of every month. V logs into every dashboard, records usage, updates spreadsheet. 30 minutes.

### Revenue Model Phases

**Phase 1 — Free (launch through initial traction).** No revenue. Build athlete base and prove product. Monitor engagement.

**Phase 2 — Freemium (when athlete base justifies it).** Free tier with basic RPS and grades. Paid tier with full breakdown, race readiness, history, advanced analysis. Stripe integration.

**Phase 3 — Events + Sponsorship (when community justifies it).** Event entry fees. Sponsor branding. Partnership revenue.

### Subscription Management (When Implemented)

Stripe for payments. Subscription tiers synced with Stripe webhooks. Automatic cancellation/reactivation. Failed payment retry via Stripe. POPIA: store only Stripe customer ID, not card details.
