---
title: master_task_list
domain: rmm
type: operations
status: active
created: 2026-04-25
updated: 2026-05-22
updated_by: claude_cowork
tags: [operations, tasks, planning]
supersedes: ""
source: RMM_Master_Task_List_Updated_2026-04-12.xlsx
related: ["[[the_four_strategic_moats]]", "[[the_competitive_landscape]]", "[[operating_philosophy]]", "[[completion_report_audit_2026_05_22]]", "[[security_audit_findings_2026_05_22]]", "[[launch_readiness_checklist]]"]
---

## Status Key

✅ Completed | 🔄 In Progress / Partial | ⬜ Not Started | ⏸ Deferred | 🔁 Recurring

---

## Quick Summary (as of import)

| Phase | ✅ Done | 🔄 Partial | ⬜ Not Started | ⏸ Deferred |
|---|---|---|---|---|
| Phase 0 — Foundation | 18 | 4 | 10 | 2 |
| V1b — Map Build | 18 | 6 | 22 | — |
| V1b+ — Enhancements | — | — | 17 | — |
| V2 — Intelligence | 11 | 9 | 64 | — |
| V3 — Scale | — | 1 | 19 | — |
| V4 — Game Maker | — | — | 14 | — |
| New Tasks (Sessions) | 22 | — | 7 | — |

---

## Phase 0 — Foundation

### Strategic Decisions
- ✅ **#1** Decide final domain name — runmadmaps.com (primary) + runmadmaps.co.za (redirect)
- ✅ **#2** Garmin at launch or post-launch? — Both Strava and Garmin at launch
- ✅ **#3** Free or freemium at launch? — Launch free, monetize later
- ✅ **#4** Set hosting budget ceiling — R1,500/month
- ✅ **#5** Decide first event format — Time Trials and Peak Hunters
- ✅ **#6** Identify beta tester cohort — V, Chloe, Nathan. Need more.
- ⏸ **#7** Trademark registration (CIPC) — Deferred. ~R1,180 for Classes 42+41. Capital not available yet.

### Planning & Documentation
- ✅ **#8** Master Document consolidation
- ✅ **#9** Create CLAUDE.md in repo — Gate G7 CLEARED. In repo root. *Blocks: Map Stage 1*
- ✅ **#10** Set up Claude Projects for each domain — Formulas, Build, Content, Business, Legal
- ✅ **#11** Create condensed formula document — Loaded to Formulas project
- ✅ **#12** Brand voice guidelines document

### Formula Calibration
- 🔄 **#13** Source real Peninsula GPX exports — V + Nathan. Open question ST3-1. *Blocks: Benchmark ceilings*
- 🔄 **#14** Validate benchmark ceilings against real data — Critical for accurate scoring. *Blocks: RPS accuracy*
- ⬜ **#15** Validate PC gradient model (RPS-11) — High priority
- ⬜ **#16** Validate TDS_BONUS_RATE (RPS-12) — High priority
- ⬜ **#17** Validate descent pace modelling (RPS-13) — Runnable vs technical descents
- ⬜ **#18** Validate PI thresholds (ST3-3) — Race Readiness accuracy

### IP & Legal Prep
- ✅ **#19** Create timestamped authorship record — V as sole author, all systems documented
- ⬜ **#20** Review Strava API Agreement terms — Attribution, rate limits, data usage, consent. *Blocks: Strava OAuth*
- ⬜ **#21** Apply for Garmin API access — Approval takes weeks, start early
- ⏸ **#22** Register trademark with CIPC — Deferred. Capital not available.

### Infrastructure Setup
- ✅ **#23** Register and configure custom domain — runmadmaps.com + .co.za. DNS configured, SSL active.
- ✅ **#24** Set up Vercel project with custom domain — Live at runmadmaps.com. Auto-deploy on push to main.
- ✅ **#25** Create Supabase project — 11 live tables now exist (subscribers, style_config, users, athletes, activities, rps_scores, rps_history, route_analyses, trails, trail_segments, trail_pois, trail_poi_links, event_types). PostGIS enabled. Confirmed 2026-05-22 audit.
- ✅ **#26** Build all Supabase tables (features, athletes, summits, etc.) — Gate G4 CLEARED. 15 new tables built 2026-04-25. *Blocks: Map Stage 3*
- ⬜ **#27** Populate features table for all 74 peaks and POIs — Gate G5. Needs G4. *Blocks: Map Stage 3*
- 🔄 **#28** Set up all environment variables in Vercel — 7 vars set. Formula values not yet (V2).
- ✅ **#29** Create .env.example in repo — All 7 variable names listed, no values.
- ✅ **#30** Set up cost tracking spreadsheet
- ✅ **#31** Register Strava application — strava.com/settings/api. DONE 2026-05-03. Client ID: 163342. Category: Training. Callback domain: runmadmaps.com.
- ⬜ **#32** Set up support email address — support@runmadmaps.co.za or similar

### Geographic Data
- 🔄 **#33** Review and confirm all GeoJSON files are clean (G2) — Peaks clean (74). Trails + contours → tileset. Routes, POIs, regions, zones, overlays, events still needed from QGIS. *Blocks: Map Stage 2*
- ✅ **#34** Peak coordinates from QGIS GeoJSON (G3 CLEARED) — 74 peaks. All rendering on live map.
- ✅ **#35** Create asset directory structure (G6 CLEARED) — Full /public/icons/ hierarchy with .gitkeep.
- ✅ **#36** Design T1 macro icons for all peak categories — peak-generic-s1.png and peak-generic-s2.png in /public/icons/peaks/

---

## V1b — Map Build (Public Ready)

### Map Stage 1 — Foundation
- ✅ **#37** Create custom Mapbox Studio base style (G1 CLEARED) — Light (Papaya Whip) primary + Dark retained for future dark mode.
- ✅ **#38** Initialise GL JS with custom Studio style URL — Token delivered via api/config.js serverless function.
- ✅ **#39** Enable 3D terrain — Exaggeration 1.5. Non-negotiable from Stage 1.
- ✅ **#40** Enable hillshade and atmospheric fog — Fog colour matched to Papaya Whip.
- ✅ **#41** Set default camera pitch — 45°, centre [18.4241, -33.9249], zoom 10, bearing 0. In DEFAULTS object.
- 🔄 **#42** Read style_config from Supabase and apply overrides — Code exists in map.js. Fails gracefully (table doesn't exist yet). Needs G4.
- ✅ **#43** Confirm map loads in full-page context — Live at runmadmaps.com/map.
- ✅ **#44** Confirm map loads in dashboard panel — `dashboard.html` wires `window.RMMMap.init('dashboard-map')`. Confirmed 2026-05-22 audit.
- ⬜ **#45** Confirm mobile responsive behaviour — Test on real devices.
- ✅ **#46** GitHub commit — Stage 1 complete

### Map Stage 2 — Static Data Layers
- 🔄 **#47** Load all GeoJSON sources — Peaks (74) + trails tileset + contours loaded. Missing: RMM challenge routes, POIs, regions, zones, overlays, events.
- ⬜ **#48** Route lines with grade-colour expressions and line-z-offset — Needs route GeoJSON from QGIS. A–F colour coding.
- ✅ **#49** Peak markers T1 — All 74 peaks visible. T1 (zoom 8–13) icon only. T2 (zoom 13+) icon + name + elevation.
- ⬜ **#50** Region boundary fill layers — Needs regions.geojson from QGIS.
- ⬜ **#51** POI markers T1 for all categories — Needs pois.geojson from QGIS + POI icons designed.
- ⬜ **#52** Zone polygon layers (Performance Zones, fire zones) — Needs zones.geojson from QGIS.
- 🔄 **#53** Determine zoom thresholds — T1: 8–13. T2: 13+. Contours 100m: 12+. Contours 20m: 13+. Footways: 13+. Steps: 14+. Set but not formally locked.
- ⬜ **#54** GitHub commit — Stage 2 complete — Pending: route lines, POIs, regions, zones.

### Map Stage 3 — Expression-Driven Styling
- ⬜ **#55** Full T1–T3 zoom expressions for all marker categories — Needs G4, G5. T1/T2 done for peaks only.
- ⬜ **#56** Tier-driven icon switching via match expression — Needs features table (G5).
- ⬜ **#57** Elevation-coloured labels
- ⬜ **#58** Route grade colour coding A–F from features table
- ⬜ **#59** Fire zone status colour from fire_zones table
- ⬜ **#60** Animation state reading from features table
- ⬜ **#61** Subscription gate logic applied
- ⬜ **#62** GitHub commit — Stage 3 complete

### Map Stage 4 — Interaction, Popups, Intro Animation
- ⬜ **#63** Build map intro animation sequence — Section 4.6 timing spec.
- ⬜ **#64** Implement show_intro_animation toggle — From athlete Supabase record.
- ⬜ **#65** Hover/tap interactions for all categories
- ⬜ **#66** Click → T4 popup for summited Tier 1/2 peaks
- ⬜ **#67** Event detail panel (video, product link, newsletter)
- ⬜ **#68** Camera flyTo on marker click / fitBounds on route
- ⬜ **#69** Wire platform connection points — Module contract.
- ⬜ **#70** Test full-page, dashboard panel, and mobile
- ⬜ **#71** GitHub commit — Stage 4 complete

### Map UI Controls
- ✅ **#72** Build zoom controls with brand styling — NavigationControl added. Styled to brand dark in map.css.
- ⬜ **#73** Build compass/bearing control — Show when rotated, reset on click.
- ⬜ **#74** Build layer toggles (collapsed by default)
- ⬜ **#75** Build map legend/key (toggle button) — Grade colours, marker categories, fire zones.
- ⬜ **#76** Build region selector (quick fly-to)

### V1b Website Pages
- ⬜ **#77** Landing page — hero with live map preview — Current landing is curtain only.
- ⬜ **#78** Landing page — the problem section
- ⬜ **#79** Landing page — the solution (four systems)
- ⬜ **#80** Landing page — map preview section
- ✅ **#81** Build coming soon components — Intelligence page + 3 sub-pages with real UI placeholders.
- ✅ **#82** Build email capture component (POPIA-compliant) — Name + email + consent checkbox → Supabase. Privacy Policy linked. **Superseded 2026-05-09:** Mailing list overlay replaced with "Create Free Account" prompt (NEW-44). Platform signups now auto-subscribe to mailing list.
- ✅ **#83** Build footer with brand badge and legal — brand, nav links, legal links, copyright, location.
- ✅ **#84** Build About page — Final copy across 11 sections.
- ✅ **#85** Build navigation — Map, About, Shop, Intelligence, Leaderboards, Dashboard. Mobile hamburger. Active state.

### V1b Quality & Milestone
- ⬜ **#86** Cross-browser testing — Chrome, Firefox, Safari, mobile.
- ⬜ **#87** Performance testing on real mobile/cellular
- ⬜ **#88** V1b milestone review — Map polish still outstanding. Email capture ✅, About ✅, Coming soon ✅.

---

## V1b+ — Map Enhancements

### Map Stage 5 — Animation System
- ⬜ **#89** Implement sprite-based LOOP animation
- ⬜ **#90** Implement CSS HOVER animations
- ⬜ **#91** Implement SEASONAL auto-activation
- ⬜ **#92** Implement EVENT-LIVE state
- ⬜ **#93** Implement CONDITIONAL state (athlete completion)
- ⬜ **#94** Test all six animation states
- ⬜ **#95** GitHub commit — Stage 5 complete

### Map Stage 6 — Overlay Illustrations
- ⬜ **#96** Implement image source loading from overlays.geojson
- ⬜ **#97** GPS-pinned illustrations with zoom threshold
- ⬜ **#98** Capture first field illustration (GPS + design)
- ⬜ **#99** Test and document overlay workflow
- ⬜ **#100** GitHub commit — Stage 6 complete

### Event Badges & Design Assets
- ⬜ **#101** Design event badge system
- ⬜ **#102** Build event detail panels in map
- ⬜ **#103** Design T2 regional icons for Tier 1+2 peaks
- ⬜ **#104** Design T3 illustrated icons for Tier 1+2 peaks
- ⬜ **#105** Design T4 bespoke popup illustrations (4 Tier 1 peaks)

---

## V2 — Intelligence & Integration

### Engine Port — GPS Stream Processor
- ✅ **#106** Port GPS Stream Processor to production — Ported to Vercel Python serverless at api/python/gps_processor.py. 2026-04-25. *Blocks: All scoring*
- ⬜ **#107** Implement RMM Moving Time with thresholds
- ⬜ **#108** Implement DEM elevation correction (batch 512) — Monitor API cost.
- ⬜ **#109** Implement all derived terrain metrics (GV, MSG, TBS, RCS)
- ⬜ **#110** Implement three-tier Pace Consistency system
- ⬜ **#111** Implement timestamp-free GPX support

### Engine Port — Route Grading V3
- ✅ **#112** Port Route Grading System to production — Ported to api/python/route_grader.py. 2026-04-25.
- ⬜ **#113** Implement 6-grade system with base class matrix
- ⬜ **#114** Implement GPS-derived modifier system (TBS + Gain)
- ⬜ **#115** Implement TDS calculation
- ⬜ **#116** Implement Effort Descriptor and Route Type Tags
- ✅ **#117** Build Route Analyzer page — `/intelligence/routes` explainer live; full `/intelligence/route-grading` tool live with GPX upload, auth-gated save, admin toggles, duplicate detection, route history. Confirmed 2026-05-22 audit.

### Engine Port — RPS
- ✅ **#118** Port RPS Engine to production — Ported to api/python/rps_engine.py. 2026-04-25.
- ⬜ **#119** Implement five components at locked weights (25/30/20/15/10)
- ⬜ **#120** Implement exponential decay (half-life 30 days)
- ⬜ **#121** Implement Consistency Modifier (sqrt softening)
- ⬜ **#122** Implement TDS-adjusted Speed Efficiency
- ⬜ **#123** Implement gradient-normalised Pace Consistency
- ⬜ **#124** Implement Layer 1 + Layer 3 (Layer 2 REMOVED)
- ⬜ **#125** Implement athlete levels and progress-within-band
- ✅ **#126** Build Fitness Tracker page — `/intelligence/fitness` live with auth gating + live RPS data; deep-dive at `/intelligence/rps`. First real score 28/Active recorded 2026-05-06. Accuracy blocked on NEW-38 (`mapStravaType()` fix). Confirmed 2026-05-22 audit.

### Engine Port — Race Readiness
- ✅ **#127** Port Race Readiness Engine to production — Ported to api/python/race_readiness.py. 2026-04-25.
- ⬜ **#128** Implement five-check system with %-to-threshold
- ⬜ **#129** Implement PI calculation (no HR, base class only)
- ⬜ **#130** Implement dynamic summary message generation
- ⬜ **#131** Implement secrecy enforcement — never expose params. [LOCKED]
- ✅ **#132** Build Race Readiness page — `/intelligence/race-readiness` tool live (route selector, verdict hero, 5 check cards, PI detail, summary); explainer at `/intelligence/readiness`. Wired to `/api/python/race-readiness`. Untestable end-to-end until graded trails are seeded. Confirmed 2026-05-22 audit.

### Engine Port — Anti-Gaming
- ✅ **#133** Port anti-gaming flags F1–F10 to production — Ported to api/python/anti_gaming.py. 2026-04-25.
- ⬜ **#134** Implement suppress/review/clean routing
- ⬜ **#135** Build flag review queue in admin dashboard

### Authentication & Integration
- ✅ **#136** Implement Strava OAuth login flow — Activity read + profile read scopes only. DONE 2026-05-03. Four endpoints: strava-login, strava-callback, session, logout. Client module: scripts/auth.js. Commit `5cbbe98`.
- ⬜ **#137** Register Strava webhook and validate — Callback to Vercel serverless.
- ⬜ **#138** Build GPS processing pipeline (webhook → score → store) — Full 10-step pipeline. Section 6.5.
- ⬜ **#139** Implement initial 90-day data sync on first connection — With progress indicator.
- ✅ **#140** Implement auth for athlete accounts — Full email/password auth system live (2026-05-08). `users` table with hashed passwords (scrypt+salt). Race numbers (RMM-XXXXXX) auto-generated. Consolidated endpoint at `api/auth/account.js` (?action=signup|signin|admin-grant). Session tokens via httpOnly cookie (30-day). Admin role system with auto-grant for founder. Strava OAuth remains as secondary connection (not login). Falls back to legacy `athletes` table for Strava-only sessions.
- ✅ **#141** Build athlete profile page — Live at /profile. Shows race number card, account details (email, gender, age, member since, role), Strava connection panel, admin controls (grant admin by email). Three-state gating: logged out → sign in CTA, logged in → full profile. Sign out clears session + localStorage.
- ⬜ **#142** Implement Garmin OAuth — Decision: Garmin at launch.

### Database & Pipeline
- ⬜ **#143** Set up production PostgreSQL with full schema
- ⬜ **#144** Implement automated daily database backups — 30-day retention.
- ⬜ **#145** Implement daily score decay cron (05:00 SAST)
- ⬜ **#146** Implement Strava deauthorisation handler
- ⬜ **#147** Build integration tests for GPS pipeline — Known GPX → expected RPS.
- ⬜ **#148** Set up GitHub Actions (linting, type checking)

### V2 Website Pages & Features
- 🔄 **#149** Dashboard page — Layout built. Map embed container exists. Placeholder data. Panels empty.
- ✅ **#150** Build route library with map and grade overlay — Admin Trail Library at `/intelligence/trail-library` + public trail browse at `/trails` + per-trail detail at `/trail/:slug` all live (Phases 2, 5, 6 of trail ecosystem build). Grade-coloured route lines via `match` expression on map. Confirmed 2026-05-22 audit.
- ⬜ **#151** Build athlete onboarding flow — OAuth → sync → score → explore. Critical UX.
- 🔄 **#152** Events page — Event detail template at /event. No listings page.
- 🔄 **#153** Shop page — 4 product cards at /shop. No images, 2 items need pricing.
- ✅ **#154** Auth gate — Full email/password auth system live. Three-state page gating on intelligence/dashboard pages: logged out → "Sign Up to View", logged in no Strava → "Connect Strava", Strava connected → live data. Admin role system replaces dev gate.
- ⬜ **#155** Build map search/filter by name
- ⬜ **#156** Implement subscription-gated map features
- ⬜ **#157** Implement athlete-personalised map — Summits, events, readiness overlays.
- ⬜ **#158** Build FAQ page
- ⬜ **#159** Implement data deletion capability (POPIA) — Leaderboard entries anonymised.

### Monitoring & Ops
- ⬜ **#160** Set up Sentry error tracking
- ⬜ **#161** Set up UptimeRobot — Ping every 5 min.
- ⬜ **#162** Set up Vercel Analytics
- ⬜ **#163** Set billing alerts on all services — Thresholds in Section 5.2.

### Events System
- ⬜ **#164** Build event creation tool (admin) — GPX upload, badge, publish/archive.
- ⬜ **#165** Build event entry purchase flow — Map badge → details → pay.
- ⬜ **#166** Implement Stripe integration for event payments
- ⬜ **#167** Build event results processing — Auto-rank by RMM Moving Time.
- ⬜ **#168** Build event results page
- ⬜ **#169** Implement event GPS corridor validation — Activity must follow event route.

### Email System
- ⬜ **#170** Set up Resend account and configure delivery
- ⬜ **#171** Build email templates
- ⬜ **#172** Implement onboarding sequence (4 emails, 14 days)
- ⬜ **#173** Implement monthly score summary email
- ⬜ **#174** Implement RPS level band notification

### Map Stage 7 — Admin Interface
- ⬜ **#175** Produce Admin Interface Spec (Gate G8) — Must be signed off before admin build. *Blocks: Admin build*
- ⬜ **#176** Build admin deployment at admin.runmadmaps.com — Separate auth.
- ⬜ **#177** Build Event Tool
- ⬜ **#178** Build Map Style Tool
- ⬜ **#179** Build Icon Manager
- ⬜ **#180** Build Feature Manager
- ⬜ **#181** Build Fire Zone Manager
- ⬜ **#182** Build Leaderboard Manager
- ⬜ **#183** Build Shop Manager
- ⬜ **#184** Build Entry Manager
- ⬜ **#185** Build Newsletter Tool
- ⬜ **#186** Build Athlete Manager
- ⬜ **#187** Build Animation Manager
- ⬜ **#188** Build Overlay Manager
- ⬜ **#189** Build admin analytics dashboard — Active users, signups, errors, costs.

### Legal & Compliance
- ✅ **#190** Draft Privacy Policy (POPIA) — Live at /privacy. Pending attorney review.
- ✅ **#191** Draft Terms of Service — Live at /terms. Pending attorney review.
- ✅ **#192** Draft Cookie Policy — Live at /cookies. Pending attorney review.
- ✅ **NEW** Draft Acceptable Use Policy — Live at /acceptable-use. Pending attorney review.
- ✅ **NEW** Build Legal index page — Live at /legal.
- 🔄 **#193** SEO — Meta tags on all pages. og-image.png exists. Structured data not yet.
- ⬜ **#194** Accessibility review — WCAG 2.1 AA. Non-map UI.

### Content & Community
- ⬜ **#195** Finalise route description template — Section 6.6 template.
- ⬜ **#196** Run 20–30 core Peninsula routes with GPS — V runs routes, captures notes + photos.
- ⬜ **#197** Write 20–30 route descriptions — Claude draft → V review.
- ⬜ **#198** Re-curate existing routes with V3 grading
- ⬜ **#199** Set up Instagram account for RMM
- ⬜ **#200** Create RMM Strava Club
- ⬜ **#201** Create 5–10 launch posts for Instagram
- ⬜ **#202** Plan first month content calendar
- ⬜ **#203** Route photography — V shoots everything.

### Soft Launch (Phase 3)
- ⬜ **#204** Internal testing with V and 3–5 trusted athletes
- ⬜ **#205** Monitor scores, grades, performance, errors
- ⬜ **#206** Fix issues found in testing
- ⬜ **#207** Adjust benchmark ceilings from real data (RPS-5)
- ⬜ **#208** Invite 20–50 Peninsula athletes for soft launch

### Public Launch (Phase 4)
- ⬜ **#209** Open registration
- ⬜ **#210** Social media launch announcement
- ⬜ **#211** Strava Club launch announcement
- ⬜ **#212** First Time Trial event within 2 weeks of launch
- ⬜ **#213** First race partnership signed

---

## V2+ — Post-Launch Revenue

- ⬜ **#214** Launch map print pre-sale campaign — No platform needed.
- ⬜ **#215** Implement Stripe subscription integration — When athlete base justifies.
- ⬜ **#216** Define free vs paid tier feature split
- ⬜ **#217** Launch subscription tiers — R49.95–R79.95/month.
- ⬜ **#218** Set up Xero or FreshBooks for accounting — When revenue begins.
- ⬜ **#219** Establish benchmark ceiling review cadence — Quarterly proposed.

---

## V3 — Leaderboards, Social & Scale

### Leaderboard System
- ⬜ **#220** Build full leaderboard system (events only) — Per-route, per-event, seasonal. Anti-gaming secured.
- 🔄 **#221** Build leaderboard UI — Page shell at /leaderboards. Sample table with placeholder data. 3 types + anti-gaming section.

### Club & Social Features
- ⬜ **#222** Build club features
- ⬜ **#223** Build social layer
- ⬜ **#224** Build Club Face-Off event type

### Advanced Map Features
- ⬜ **#225** Build locked map zones
- ⬜ **#226** Build Performance Zone polygons
- ⬜ **#227** Build Performance Zone proximity alerts

### Partnerships & Growth
- ⬜ **#228** Approach running stores for leaderboard partnerships — After 100+ athletes.
- ⬜ **#229** Approach race organisers for grading co-branding — After grading recognised.
- ⬜ **#230** Build partnership proposal template
- ⬜ **#231** Launch ambassador programme [SCALE]
- ⬜ **#232** Approach tourism operators — Longer-term.

### Two-Sided Marketplace
- ⬜ **#233** Build race organiser dashboard — Featuring fees, lead gen.
- ⬜ **#234** Implement entry gateway commission (5–10%)

### SaaS Module Licensing
- ⬜ **#235** Package Route Analyzer as standalone SaaS
- ⬜ **#236** Package Fitness Tracker as standalone SaaS
- ⬜ **#237** Package Ops Board as standalone SaaS
- ⬜ **#238** Build SaaS marketing/landing pages

### Open Question Resolution (V3 Calibration)
- ⬜ **#239** Resolve Effort Descriptor coverage gaps (RG-7)
- ⬜ **#240** Resolve Route Type Tag overlap (RG-8)
- ⬜ **#241** Validate TDS sensitivity at TBS ceiling (RG-9)
- ⬜ **#242** Validate flag thresholds (AG-1)
- ⬜ **#243** Design anti-gaming review workflow (AG-2)
- ⬜ **#244** Design athlete comms for flagged activities (AG-3)
- ⬜ **#245** Implement F4 (Linear GPS Trace) fully
- ⬜ **#246** Evaluate OSM surface classification (ST3-6)

---

## V4 — Game Maker Licensing

### Platform Preparation
- ⬜ **#247** Abstract Peninsula calibration into geography config layer
- ⬜ **#248** Build geography onboarding system for operators
- ⬜ **#249** Build multi-geography admin (operator dashboard)
- ⬜ **#250** Document calibration methodology for operator use

### Legal & Commercial
- ⬜ **#251** Develop Game Maker licensing agreement template
- ⬜ **#252** Consult IP attorney on patentability
- ⬜ **#253** Define licensing pricing model

### First Licensed Geography
- ⬜ **#254** Identify and approach first licensing partner
- ⬜ **#255** Calibrate engine for first non-Peninsula geography
- ⬜ **#256** Launch first licensed geography
- ⬜ **#257** Iterate licensing model based on learnings

### Scale
- ⬜ **#258** License to 2–4 additional geographies
- ⬜ **#259** Build cross-geography leaderboard/comparison
- ⬜ **#260** Evaluate device strategy feasibility

---

## New Tasks Added During Build Sessions (1–4)

- ✅ **NEW-1** Create Mapbox Studio light (Papaya Whip) base style — mapbox://styles/valkenmadness/cmnt2jt3w002f01qug4q7hz7l
- ✅ **NEW-2** Create Mapbox Studio dark base style — mapbox://styles/valkenmadness/cmnsvhzns002701qwc1xshumo. Retained for dark mode.
- ✅ **NEW-3** Upload consolidated trails GeoJSON to Mapbox tileset — ID: valkenmadness.2lov39bd. 18,054 features.
- ✅ **NEW-4** Upload 10m contour data to Mapbox tileset — ID: valkenmadness.5civjhdm.
- ✅ **NEW-5** Clean and consolidate peaks.geojson — 74 peaks, stripped OSM noise.
- ✅ **NEW-6** Build T1 and T2 peak marker layers — T1: zoom 8–13. T2: zoom 13+, name + elevation.
- ✅ **NEW-7** Build trail line layers (4 types) — path (dashed), track (solid), footway (subtle), steps (dotted). TRAIL_STYLES config.
- ✅ **NEW-8** Build contour line layer (data-driven 20m/100m) — Single layer with case expressions. CONTOUR_STYLES config.
- ✅ **NEW-9** Build admin bypass gate for dev access — ?admin=madmaps sets localStorage flag. Admin nav links injected.
- ✅ **NEW-10** Build standardised page header pattern — Dark bar with label/title/subtitle. 2px accent line.
- ✅ **NEW-11** Build Intelligence hub page (/intelligence) — 3 tool sections with dark/light rhythm.
- ✅ **NEW-12** Build Intelligence sub-pages (fitness/routes/readiness) — Full content: component cards, grade cards, check cards.
- ✅ **NEW-13** Build Leaderboards page — Rules, 3 types, sample table, anti-gaming section.
- ✅ **NEW-14** Build Dashboard page shell — 4-row layout: map + events, activity cards, analysis panels, collection panels.
- ✅ **NEW-15** Build Shop page shell — 4 product cards. Placeholder images/pricing.
- ✅ **NEW-16** Build Product detail page template — Two-column layout. Cape Peninsula Trail Map as flagship.
- ✅ **NEW-17** Build Event detail page template — Route stats, entry tiers, map preview placeholder.
- ✅ **NEW-18** Generate favicon from logo — favicon.png in /public/images/
- ⬜ **NEW-19** Create OG image for social sharing — `og-image.png` referenced in `<meta og:image>` and `<meta twitter:image>` on `pages/map.html` but file **does not exist** in `/public/images/`. Verification 2026-05-01 confirmed missing. Tracked as Bug 2 in [[website_build_status_issues]].
- ⬜ **NEW-20** Implement dark/light mode toggle for map — Both Studio styles exist. Needs toggle UI + colour config swap.
- ⬜ **NEW-21** Build style_config Supabase table — Feeds TRAIL_STYLES, PEAK_STYLES, CONTOUR_STYLES from Supabase.
- ⬜ **NEW-22** Re-export trail data from QGIS with V's classification — V wants own categories instead of OSM highway types.
- ⬜ **NEW-23** Fix 8 peaks — fid 21, fid 23 unnamed. Oppelskop, Ascension Buttress, Blinkwater Needle, Varingkop, ERF #1, Klein Slangkop missing elevation.
- ⬜ **NEW-24** Attorney review of all 4 legal documents — Remove draft notices, switch to index,follow.
- ⬜ **NEW-25** Drop old consent column from subscribers table — Old boolean column superseded by consent_given.
- ✅ **NEW-26** Rename Maclear's Beacon T3 + T4 icon files (remove apostrophe) — `t3-peak-maclears-beacon.svg`, `t4-peak-maclears-beacon.svg`. Closes Bug 2 (old numbering) in [[website_build_status_issues]]. Commit `1a98108` (2026-04-30).
- ✅ **NEW-27** Delete pre-launch curtain dead code — `scripts/main.js`, `styles/main.css`. Commit `35b6a56` (2026-04-30). Orphaned/Legacy section in [[website_key_files]] cleared.
- ✅ **NEW-28** Add grade colour match expression to route lines — `rmm-routes` `line-color` now uses `match` on `properties.grade` (A–F) instead of hardcoded `#FF4E50`. Live in deployed `map.js`. Updates Map Stage 3 status in [[website_build_status_overview]].
- ✅ **NEW-29** Replace `/intelligence` hub developer placeholder copy — Real h1, subtitle, three tool sections (Runner Performance Score / Objective Route Grading / Race Readiness Check), and three USP h4s per feature strip. Secondary CTA labels reflect engine state ("Live Now →" for Routes, "Coming Soon →" for Fitness/Readiness). Committed locally as `ad1db2c` (2026-05-01); push to `origin/dev` pending. Resolves the four-session loop tracked in `2026-05-01_handover_to_opus`.
- ✅ **NEW-30** Strava OAuth complete — Four endpoints in `api/auth/` (strava-login, strava-callback, session, logout). httpOnly cookie session. Auto token refresh. Client ID 163342. Scopes: `read,activity:read`. Athletes table with RLS. Commit `5cbbe98` (2026-05-03).
- ✅ **NEW-31** Supabase production schema — `activities`, `rps_scores`, `rps_history`, `route_analyses` tables created using `IF NOT EXISTS` pattern (Supabase SQL Editor atomic-transaction-aware). Migration files: `supabase_athletes_migration.sql`, `supabase_activities_migration.sql`. (2026-05-05).
- ✅ **NEW-32** RPS endpoint early-return — `calculate_rps.py` returns `{rps:0, level:Foundation}` if no activities, avoiding crashes on missing engine env vars. Lets Fitness page render gracefully pre-sync. (2026-05-05).
- ✅ **NEW-33** All 93 formula env vars set in Vercel Production — 60 grading + 33 RPS/readiness/anti-gaming. Bulk import via `vercel-paste-ready.txt`. (2026-05-06).
- ✅ **NEW-34** UUID→TEXT migration — `activities.athlete_id`, `rps_scores.athlete_id`, `rps_history.athlete_id` altered from UUID to TEXT. FK `activities_athlete_id_fkey` dropped (different ID schemes: Strava numeric vs internal UUID). Single biggest unblock — fixed both activity sync (27/27 errors) and RPS calculation. (2026-05-06).
- ✅ **NEW-35** Cross-discipline bonus ÷100 fix — `rps_engine.py` line 372: `bonus = weighted_avg * (bonus_pct / 100.0)` instead of raw multiplier. Was producing 100/Elite from individual scores in 25–28 range. Commit `15353f3`. (2026-05-06).
- ✅ **NEW-36** Race Readiness dynamic route selector — `race_readiness_check.py` gained "list mode" for graded routes (avoids needing a new function at 12/12 limit). `intelligence-readiness.html` now fetches the list instead of using hardcoded GeoJSON slugs. Commit `81153fc`. (2026-05-06).
- ✅ **NEW-37** First live RPS score from real data — 28/Active from 27 Strava activities (23 road, 1 trail, 3 hike). Engine Build Sequence Phases 1–3 now LIVE end-to-end. (2026-05-06).
- ⬜ **NEW-38** Fix `mapStravaType()` misclassification — Strava labels most runs as "Run", which the function defaults to "road". 23/27 of synced activities are mountain trails being scored against road benchmarks. Single biggest accuracy improvement available right now.
- ⬜ **NEW-39** Wire dashboard panels — RPS, Race Readiness, Lifetime Summary, Peak Hunter, Cave Diver panels currently are header divs with empty bodies. Fitness page already proves the pattern; repeat for the dashboard.
- ⬜ **NEW-40** Pull formula files from git tracking — `vercel-paste-ready.txt`, `set-env-vars.ps1`, `RMM_Route_Analyzer_Env_Vars.xlsx` contain all 93 formula values; violates own `.env.example` rule. `.gitignore` + `git rm --cached` fix. ~5 minutes. See [[handoff_state_of_build_2026_05_07]].
- ⬜ **NEW-41** Restore activity ↔ athlete linkage at DB level — FK was dropped in NEW-34 to allow type change. Currently linked by application convention only. Even a non-FK indexed lookup would clean up future analytics queries.
- ✅ **NEW-42** Email/password auth system — Full signup/signin/profile/signout flow. `users` table in Supabase with `id`, `email`, `password_hash`, `first_name`, `last_name`, `gender`, `age`, `race_number`, `role`, `session_token`, `strava_connected`, `strava_athlete_id`. Passwords hashed with `crypto.scryptSync` (64-byte key, random 32-byte salt). Race numbers `RMM-XXXXXX` (100000–999999) with collision check. Admin auto-grant for founder email. Pages: `/signup`, `/signin`, `/profile`. (2026-05-08).
- ✅ **NEW-43** Vercel Hobby plan consolidation — Reduced from 15+ serverless functions to exactly 12 to stay under Hobby plan limit. Consolidated `signup.js` + `signin.js` + `admin-grant.js` → `account.js` (query-param routing). Consolidated `config.js` → `session.js?type=mapconfig`. Renamed 8 Python helper modules with underscore prefix (Vercel ignores `_`-prefixed files). All imports updated. Reversible when upgrading to Pro. (2026-05-08).
- ✅ **NEW-44** Overlay swap + signup auto-subscribe — Replaced mailing list lightbox on map page with "Create Free Account" overlay (CTA disabled as "Coming Soon"; set `RMM_OVERLAY_LIVE = true` in map.js to activate). Overlay now suppressed for logged-in users (session cookie check) in addition to localStorage. Platform signups auto-insert into `subscribers` table (`source: 'platform-signup'`). `localStorage.rmm_subscribed` set on signup success. Fixed `.auth-submit` button overflow on race number card (`box-sizing: border-box`). Deployed to production 2026-05-09.
- ⬜ **NEW-45** Reverse Vercel consolidation after Pro upgrade — When upgrading to Vercel Pro ($20/month), split `account.js` back into `signup.js`, `signin.js`, `admin-grant.js`; split `session.js` map config back into `config.js`; rename Python helpers back (remove underscore prefix). ~30 min task.
- 🔴 **NEW-46** Remove formula IP files from git history — Six tracked files at repo root expose all 93+ formula env vars: `vercel-paste-ready.txt`, `HANDOVER-RPS-ENV-VARS.md`, `vercel-env-template.txt`, `set-env-vars.ps1`, `RMM_Route_Analyzer_Env_Vars.xlsx`, `vercel-dds-env-vars.txt`. Sequence: confirm GitHub repo visibility → `git rm` → `.gitignore` → `git filter-repo` to scrub history → force-push. ~90 min. **Critical.** Supersedes NEW-40 (which only addressed three of the six files). See [[security_audit_findings_2026_05_22]].
- 🔴 **NEW-47** Fix `.gitignore` UTF-16 encoding + untrack `__pycache__` — Last line of `.gitignore` is UTF-16-encoded; rule does not match. Six `.pyc` files currently tracked in `api/python/__pycache__/` (`_config`, `_descent_grader`, `_gps_processor`, `_supabase`, `trails`, `upload`). Fix: re-save `.gitignore` as UTF-8/LF, `git rm -r --cached api/python/__pycache__`. ~15 min. **Critical.**
- 🔴 **NEW-48** Patch Strava OAuth `state` as CSRF token — `strava-login.js` puts `return_to` URL into `state`; `strava-callback.js` decodes without verification. Account-linking CSRF risk (see [[security_audit_findings_2026_05_22]]). Fix: generate random nonce at login, sign with HMAC, store in signed cookie, verify on callback. ~30 min. **Critical.**
- 🟠 **NEW-49** Add CSP + HSTS + Permissions-Policy headers — `vercel.json` `headers` array currently sets only `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`. Missing: `Content-Security-Policy`, `Strict-Transport-Security`, `Permissions-Policy`. ~30 min. **High.**
- 🟠 **NEW-50** Commit-or-discard 24 modified files — Working tree is dirty (5 auth files, 6 Python engines, 6 HTML pages, 2 SQL migrations, `vercel-paste-ready.txt`, legacy state-of-build .md, `.claude/settings.local.json`). Local production does not match deployed production. ~30–60 min. **High.**
- 🟠 **NEW-51** Add observability stack (Sentry + UptimeRobot + Vercel Analytics) — Cross-link #160, #161, #162. ~2 hr. **High.**
- 🟠 **NEW-52** Rate limiting on `/api/subscribe`, `/api/python/analyze` (public), `/api/auth/strava-login` — Vercel edge middleware or table-level check + IP hash. ~1 hr. **High.**
- 🟠 **NEW-53** `encodeURIComponent` every `session_token` URL interpolation — Six files: `account.js`, `logout.js`, `session.js`, `strava-activities.js`, `strava-callback.js`, `trails.py`. Pattern already correct in `account.js:75` for email. ~30 min. **High.**
- 🟡 **NEW-54** Split `pages.css` by page-family prefix — 9,340 lines today. Failed once (May 11 brace-imbalance incident). Suggested split: `pages-intel.css`, `pages-trails.css`, `pages-auth.css`, `pages-dashboard.css`, `pages-shop.css`, `pages-legal.css`. ~2 hr. **Medium.**
- 🟡 **NEW-55** Delete `dev` branch (local + origin) — [[release_workflow]] (updated 2026-05-12) says everything pushes to `main` and `dev` is gone. Branch still exists. ~5 min. **Medium.**
- 🟢 **NEW-56** Tidy 3 legacy `.md` files at repo root — `RMM_State_of_the_Build_2026-05-07.md`, `RMM_Instruction_Landing_Page_Foundation.md`, `RMM_Map_Stage1_Instruction.md`. Move to brain `archive/` or `git rm`. ~10 min. **Low.**
- 🟢 **NEW-57** Tidy 2 vault-root strays — `Untitled.base`, `Untitled.canvas` at vault root. Either rename properly or archive. ~5 min. **Low.**
- 🟢 **NEW-58** Move `_work/_handoffs/phase4_handover.md` from repo to brain — Brain protocol says handoffs live in `rmm/_work/_handoffs/`. Also produce or note-as-missing retrospective handoff briefs for phases 2, 3, 5, 6. ~5–15 min. **Low.**

---

## 2026-05-22 audit pass

A full read-only audit was performed 2026-05-22 (Claude in Cowork mode). See `outputs/rmm_audit_report_2026-05-22.md` (850-line audit report) and [[completion_report_audit_2026_05_22]] / [[security_audit_findings_2026_05_22]] in the brain for the structured findings. The audit confirmed Phases 1–6 of the Trail Ecosystem build are deployed end-to-end, flipped statuses on #25, #44, #117, #126, #132, #150, and surfaced 13 new items (NEW-46 through NEW-58) — three Critical, five High, two Medium, three Low. The most urgent is NEW-46: formula IP files have been tracked in git since 2026-05-07 (originally logged as NEW-40, expanded here to cover all six files) and need history-rewriting, not just removal from HEAD.

---

## 2026-05-07 audit pass

A full review against the codebase was performed on 2026-05-07. See [[handoff_state_of_build_2026_05_07]] for the comprehensive State of the Build report. Key findings folded back into this list above as NEW-30 through NEW-41. The launch readiness checklist ([[launch_readiness_checklist]]) was rewritten in the same pass.

---

## Ongoing — Continuous Tasks

- 🔁 **#261** Monthly cost review — 1st of month. 30 min. Update spreadsheet, check all dashboards.
- 🔁 **#262** Weekly platform review — Every Monday. 15 min. Active users, signups, activities, errors, flags.
- 🔁 **#263** Monthly analytics review — 1st of month. 30 min. Retention, routes, RPS distribution, cost/user.
- 🔁 **#264** Quarterly benchmark ceiling review — Adjust ceilings from real population data.
- 🔁 **#265** Social media posting — 3–4/week. Mon=route, Wed=insight, Fri=culture.
- 🔁 **#266** Monthly content planning — Last day of month. 30 min.
- 🔁 **#267** Community management — V's job. Not delegatable.
- 🔁 **#268** Route photography on training runs — Hero + social + detail per route.
- ✅ **#270** GPS peak coordinate correction — 74 peaks sourced from QGIS. G3 CLEARED.
- 🔁 **#271** Run new routes for GPS data + descriptions
- 🔁 **#272** Capture GPS for field overlay illustrations — Garmin → Sheets → design → deploy.
