---
title: formula_lab_architecture_overview
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: claude_code
tags: [codebase, formula-lab, architecture, overview]
supersedes: ""
related: ["[[formula_lab_engine_files]]", "[[formula_lab_config_and_data_layer]]", "[[formula_lab_api_and_frontend]]", "[[formula_lab_build_status_overview]]", "[[formula_development_history]]", "[[formula_lab_build_status_issues]]", "[[formula_lab_decisions]]"]
---

# Formula Lab — Architecture Overview

## 1. Project Structure

```
E:\13 - RMM Fitnes and Route Tracker TESTING\
├── .env                              — All formula values (gitignored, TRADE SECRET)
├── .env.example                      — Variable name skeleton, no values (committed)
├── .gitignore                        — Ignores .env, db, exports, srtm, caches
├── README.md                         — Setup instructions, formula system status table
├── start.sh                          — Bash launch: starts uvicorn + vite in background
├── start.bat                         — Windows launch: opens two cmd windows + browser
├── formula_lab_architecture.md       — This document
│
├── backend/
│   ├── __init__.py                   — Empty package marker (enables relative imports)
│   ├── app.py                        — FastAPI server, all API endpoints (~1214 lines)
│   ├── config.py                     — All formula constants loaded from env vars
│   ├── database.py                   — SQLite operations (5 tables, all CRUD)
│   ├── gps_processor.py              — Core GPS stream processor: haversine, elevation,
│   │                                   splits, terrain metrics, pace consistency
│   ├── route_grader.py               — Route Grading V3: class A–F, TDS, effort
│   │                                   descriptor, route type tag
│   ├── rps_engine.py                 — RPS scoring: exponential decay, gradient-
│   │                                   normalised PC, TDS-adjusted SE, three layers
│   ├── race_readiness.py             — Five-check race readiness assessment
│   ├── anti_gaming.py                — Nine validation flags (F1–F10) on upload
│   ├── dem_lookup.py                 — SRTM .hgt tile reader, bilinear interpolation
│   └── requirements.txt              — Python dependencies
│
├── data/
│   └── rmm_formula_lab.db            — SQLite database (gitignored, persists across restarts)
│
├── exports/                          — JSON export destination (gitignored)
│
└── frontend/
    ├── index.html                    — Vite HTML entry point
    ├── package.json                  — npm manifest
    ├── vite.config.js                — Vite: React plugin, Tailwind plugin, /api proxy → :8000
    ├── eslint.config.js              — ESLint rules
    │
    ├── public/
    │   ├── favicon.svg
    │   └── icons.svg
    │
    └── src/
        ├── main.jsx                  — React entry: StrictMode + BrowserRouter + App
        ├── App.jsx                   — Root: nav bar, global profile state, route table
        ├── api.js                    — All fetch calls (single api object, 25+ methods)
        ├── index.css                 — Dark theme CSS vars, global resets, recharts overrides
        │
        ├── views/
        │   ├── RouteAnalyzer.jsx     — Route library: upload, list, detail, map, elevation
        │   ├── FitnessTracker.jsx    — Training tracker: upload, RPS, layers, activity table
        │   ├── RaceReadiness.jsx     — Five-check readiness: route + profile selector,
        │   │                           verdict, check cards
        │   └── CalibrationPanel.jsx  — Formula editor: sliders, live RPS preview,
        │                               report export
        │
        └── components/
            ├── ui.jsx                — Shared primitives: Card, Stat, Button, Select,
            │                           Tabs, FileUpload, badges, formatters
            ├── RPSBreakdown.jsx      — RPS score display: headline, bar chart, components
            ├── ElevationProfile.jsx  — Recharts AreaChart: elevation vs distance
            ├── RouteMap.jsx          — Leaflet map with polyline trace + start marker
            ├── InlineRename.jsx      — Double-click-to-edit name field
            └── UploadConfirmModal.jsx — Route upload preview modal (defined but bypassed
                                        in current RouteAnalyzer flow)
```

---


## 8. Dependencies

### Backend — `backend/requirements.txt`

| Package | Version constraint | Purpose |
|---|---|---|
| `fastapi` | >=0.104.0 | Web framework + OpenAPI |
| `uvicorn` | >=0.24.0 | ASGI server |
| `python-dotenv` | >=1.0.0 | `.env` file loader |
| `python-multipart` | >=0.0.6 | Form/file upload parsing |
| `pydantic` | >=2.0.0 | Request body models |

No external dependencies for GPS processing, database, or maths — uses only Python stdlib (`math`, `xml.etree.ElementTree`, `sqlite3`, `struct`, `json`, `uuid`, `datetime`, `pathlib`). Runtime: Python 3.14.

### Frontend — `frontend/package.json`

| Package | Version | Purpose |
|---|---|---|
| `react` | ^19.2.4 | UI framework |
| `react-dom` | ^19.2.4 | DOM renderer |
| `react-router-dom` | ^7.13.2 | Client-side routing |
| `react-leaflet` | ^5.0.0 | Leaflet map wrapper |
| `leaflet` | ^1.9.4 | Interactive maps |
| `recharts` | ^3.8.1 | Bar chart + area chart |
| `tailwindcss` | ^4.2.2 | Utility CSS |
| `@tailwindcss/vite` | ^4.2.2 | Tailwind Vite integration |
| `vite` | ^8.0.1 | Build tool + dev server |
| `@vitejs/plugin-react` | ^6.0.1 | React Babel transform |

---


## 9. Setup and Run

**Prerequisites:** Python 3.10+ (runtime uses 3.14), Node.js 18+, npm.

**Install:**
```bash
pip install -r backend/requirements.txt
cd frontend && npm install
```

**Configure:** Copy `.env.example` to `.env` at project root. Fill in all values. `.env` must exist before the backend starts — any missing key raises `ValueError` immediately.

**Optional SRTM elevation data:** Download `S34E018.hgt`, `S35E018.hgt` from USGS EarthExplorer, place in `backend/srtm_data/`. Without these files, elevation uses raw GPS altitude with smoothing. `dem_corrected: true/false` is recorded on each activity.

**Run:**
- Windows: `start.bat` — opens two cmd windows (backend + frontend), launches browser.
- Linux/Mac: `./start.sh` — starts both in background, Ctrl+C kills both.
- Manual (two terminals):
  ```bash
  python -m uvicorn backend.app:app --reload --port 8000
  cd frontend && npm run dev
  ```

**URLs:**
- Frontend: `http://localhost:5173`
- Backend API: `http://localhost:8000`
- API docs (auto-generated): `http://localhost:8000/docs`

**Vite proxy:** All `/api/*` requests in the frontend are proxied to `http://localhost:8000`. The `api.js` base URL is just `/api`.

**Database:** Created automatically on first backend startup at `data/rmm_formula_lab.db`. Four default profiles seeded: V, Elite, Mid-Pack, Beginner.

---


## 10. Architectural Notes for Porting

**1. All formula values are external to code.** The code contains only structure. Every threshold, weight, ceiling, and band boundary lives in `.env`. A port must replicate both the code structure and supply the env values. The `/api/config` endpoint returns all current values for inspection.

**2. `raw_data` is the central bus.** The entire GPS processor output dict is stored verbatim as JSON. No normalisation into relational columns (only `activity_type`, `date`, `purpose`, `profile_id` are columns). A port must decide whether to keep this blob pattern or normalise.

**3. Profile "V" has backward-compat logic.** Activities uploaded before multi-profile support (`profile_id IS NULL`) are owned by the "V" profile. The `profile_id = ? OR profile_id IS NULL` pattern appears in 6 places in `database.py`. Any port must replicate this or migrate the old data.

**4. Three-tier pace consistency exists in two places** — `GPSStreamProcessor._calculate_pace_consistency()` (raw, stored as `pace_consistency_score` in `raw_data`) and `_compute_gradient_pc()` in `rps_engine.py` (gradient-normalised, computed at RPS time from stored `km_splits`). Both use identical trimming logic (value-sorted, population std dev). The RPS engine prefers gradient-normalised and falls back to stored. A port must implement both or accept that old activities without `km_splits.gradient` will use the raw score.

**5. Layer 2 was intentionally removed.** `calculate_all_layers()` returns L1 (per-discipline) and L3 (overall) only. The docstring explains: systematic +19–31% inflation from cross-discipline scoring against wrong ceilings.

**6. `_compute_gradient_pc` is exported at module level.** It is imported by both `rps_engine.py` (internal scoring) and `app.py` (report export). Both call sites must pass identical arguments including `ramp_ceiling` and `ramp_power`. Any port that separates these call sites must keep the signatures synchronised.

**7. DEM is optional infrastructure.** The system is fully functional without SRTM tiles. `dem_corrected: bool` on each activity records which mode was used. Elevation quality affects all terrain metrics downstream.

**8. `UploadConfirmModal.jsx` is defined but bypassed.** `RouteAnalyzer.jsx` calls `api.uploadRoute()` directly on file drop. The modal component exists and is complete but is not wired into the current flow.

**9. Schema migrations run inline.** No migration tool. All `ALTER TABLE` statements are in `database.init_db()` wrapped in `try/except OperationalError`. Each migration runs once and silently succeeds on subsequent starts. A port using a migration tool should extract these into proper migration scripts.

**10. Secrecy Rule.** Formula values (weights, thresholds, ceilings) are never exposed in API responses to external consumers. The `/api/report/export` endpoint includes variable names but not their values. The Calibration Panel is a local-only interface and is the only surface that exposes values, intentionally, for the formula designer.
