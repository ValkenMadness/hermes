---
title: platform_architecture_and_tech_stack
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-08
updated_by: claude_opus_cowork
tags: [product, architecture, tech-stack]
supersedes: ""
related: ["[[data_architecture]]", "[[website_architecture]]", "[[platform_pages_and_ux]]", "[[map_and_website_architecture]]", "[[product_vision]]", "[[website_deployment_and_devops]]"]
---

This section merges the Website Build Manual's implementation specifics with the Workforce Manual's operational context.

### Production Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Frontend | Vanilla JavaScript, HTML, CSS | NOT React. The Formula Lab uses React/Vite/Tailwind, but the live website is vanilla JS. |
| Map Engine | Mapbox GL JS | Loaded via CDN. Custom Mapbox Studio style URL. |
| Backend (local dev) | Node.js + Express (server.js) | For local development and testing. |
| Backend (production) | Vercel serverless functions (api/) | Auth, token delivery, Python scoring engines. 12-function Hobby plan limit — helpers use underscore prefix to avoid counting. |
| Database | Supabase (PostgreSQL) | Shared data layer for all five modules. Auth, storage, realtime. |
| Static Data | GeoJSON files | Canonical for all geographic data. Generated from QGIS. |
| Hosting | Vercel | Auto-deploys on push to master branch. |
| Version Control | GitHub | Single repository: run-mad-maps. |
| Domain | runmadmaps.com | Custom domain live. runmadmaps.co.za redirects. |
| Admin (future) | Separate Vercel deployment | admin.runmadmaps.com (provisional). |

**Development Environment:** Windows. PowerShell only. Never Unix/bash syntax. VS Code editor. Deployment pipeline: VS Code → Git commit → Push to GitHub main → Vercel auto-deploys.

### Future Stack Additions (V2+)

| Addition | Technology | Notes |
|----------|-----------|-------|
| Authentication | Custom lightweight auth (NOW LIVE) | Email/password signup with scrypt hashing. Strava OAuth as secondary connection (not login). Session via httpOnly cookie. Moved to Production Stack as of 2026-05-08. |
| Payments | Stripe | For subscription model and event entries. |
| Activity Import | Strava OAuth + Garmin Connect API | V2. |
| Email | Resend | Developer-friendly, good free tier, transactional email. |
| Monitoring | Vercel Analytics + Sentry + UptimeRobot | Error tracking, uptime, performance. |

The Formula Lab (React/Vite/Tailwind + Python/FastAPI + SQLite) is lab-only, never deployed. When lab modules are rebuilt as ship-quality modules, they use the production stack.

### The Five Modules

| Module | Purpose | Status | Type |
|--------|---------|--------|------|
| Interactive Map | Spatial interface. The centrepiece. | Being built — first ship-quality module. | Athlete-facing |
| Fitness Tracker | RPS scoring, activity history, level progression. | Lab proof of concept. Ship version to rebuild. | Athlete-facing |
| Route Analyzer | Route grading, TDS, effort descriptors. | Lab proof of concept. Ship version to rebuild. | Athlete-facing |
| Race Readiness | Five-check readiness assessment per target route. | Lab proof of concept. Ship version to rebuild. | Athlete-facing |
| Admin Interface | Operational nerve centre. | Specified. Full spec document required. | Operational |

### The Modular Isolation Principle `[LOCKED]`

The map never imports code from another module. All cross-module communication happens through the shared Supabase data layer or through defined event callbacks. No exceptions. This enables: independent module development, the map appearing in full-page and dashboard contexts from one codebase, and future mobile app embedding.

### Security Rules `[LOCKED]`

- Mapbox token: .env locally, Vercel env vars in production. Never in codebase. Ever.
- .gitignore excludes .env and node_modules at all times.
- Mapbox token restricted to run-mad-maps.vercel.app domain.
- No tokens, keys, or secrets of any kind ever enter the codebase.
- RPS formula weights and benchmark ceilings: environment variables only.
- Pre-integration security checklist before any new API or payment integration.
- Admin interface: separate authentication from public site.
