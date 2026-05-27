---
title: platform_pages_and_ux
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-21
updated_by: claude_cowork
tags: [product, ux, pages]
supersedes: ""
related: ["[[product_vision]]", "[[platform_architecture_and_tech_stack]]", "[[map_build_sequence]]", "[[trail_ecosystem_design]]", "[[website_component_map]]"]
---

### Website Structure

| Page | URL Path | Purpose | Status |
|------|---------|---------|--------|
| Entry Redirect | / | Meta-refresh redirect to /map | Live |
| Map (Full Page) | /map | Full-viewport interactive Mapbox map. Primary user experience. 3D terrain, peaks, caves, routes, POIs. | Live |
| Trails Browse | /trails | Public trail card grid with grade/event/sort filters. Links to detail pages. | Live |
| Trail Detail | /trail/:slug | Public trail view — grades, segments, elevation profile, mini-map, linked POIs. | Live |
| About | /about | Origin story. Platform vision. The four systems. Founder. Peninsula. | Live |
| Sign Up | /signup | Account creation with race number reveal. Strava OAuth. | Live |
| Sign In | /signin | Session login via Strava OAuth. | Live |
| Profile | /profile | Athlete profile. Settings. Subscription management. | Live |
| Dashboard | /dashboard | Module panels with embedded map. Placeholder content. | Live (admin-gated) |
| Intelligence Hub | /intelligence | Marketing page for the three intelligence tools. | Live (admin-gated) |
| RPS Deep-Dive | /intelligence/rps | Full RPS breakdown with live score. Three-state auth gating. | Live (admin-gated) |
| Route Grading Tool | /intelligence/route-grading | Interactive GPX grading. Drag-drop upload. Admin save/toggle. | Live (admin-gated) |
| Race Readiness | /intelligence/race-readiness | 5-check assessment for athlete vs route. | Live (admin-gated) |
| Trail Library | /intelligence/trail-library | Admin trail management — GPX upload, grading, segments, snip, status. | Live (admin-gated) |
| POI Manager | /intelligence/poi-manager | Admin POI CRUD — 14 categories, coordinates, map preview. | Live (admin-gated) |
| Leaderboards | /leaderboards | Coming-soon placeholder. | Live (admin-gated) |
| Shop | /shop | 4-product grid, all "coming soon". | Live (admin-gated) |
| Product Detail | /product | Single product template (Cape Peninsula Trail Map). | Live (admin-gated) |
| Event Detail | /event | Single event template (Chase the Dragons Tail). | Live (admin-gated) |
| 404 | (auto) | On-brand error page — "Trail not found. You've gone off the map." | Live |
| Privacy Policy | /privacy | POPIA-compliant privacy policy. | Live |
| Terms of Service | /terms | Platform terms. | Live |
| Cookie Policy | /cookies | Cookie disclosure. | Live |
| Acceptable Use | /acceptable-use | Usage rules. | Live |
| Legal Hub | /legal | Links to all legal pages. | Live |

### Landing Page Content Specification

Required sections (in order):
1. Hero: Full-bleed map preview. Headline in brand voice. Single CTA: "Explore the Map."
2. The Problem: What's missing on the Peninsula.
3. The Solution: The four systems — Map, Route Grading, RPS, Race Readiness.
4. The Map Preview: Embedded map component or high-quality visual.
5. Coming Soon: Real UI placeholders, not generic text.
6. Email Capture: POPIA-compliant newsletter signup.
7. Footer: Brand badge. Links. Legal.

### First-Visit Experience

1. Landing page loads. Hero communicates value immediately.
2. Visitor clicks "Explore the Map."
3. Map page loads. Intro animation plays (logo overlay → Peninsula overview → resting state).
4. Map is fully interactive. No sign-up wall at V1b.
5. Coming Soon components show what's being built.
6. Event marker engagement triggers newsletter capture prompt.

### Navigation (Current Implementation)

**All users (public nav):** Map (`/`), Trails (`/trails`), About (`/about`), Sign In / Profile (toggled by auth state).

**Admin users (additional links):** Shop (`/shop`), Intelligence (`/intelligence` with dropdown: RPS, Route Grading, Race Readiness, Trail Library, POI Manager), Leaderboards (`/leaderboards`), Dashboard (`/dashboard`).

Admin links appear when `localStorage.rmm_admin === 'true'` (set on admin login) or dynamically injected when auth.js confirms admin role.

**Footer (all pages except / and /map):** Map, Trails, About + admin-gated: Shop, Intelligence, Leaderboards, Dashboard. Legal links: Privacy, Terms, Cookies, Acceptable Use.
