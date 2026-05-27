---
title: handoff_engine_port_to_vercel
domain: rmm
type: handoff
status: complete
created: 2026-04-25
updated: 2026-04-25
updated_by: claude_cowork
tags: [handoff, engines, vercel, python, port]
supersedes: ""
related: ["[[formula_lab_engine_files]]", "[[formula_lab_architecture_overview]]", "[[formula_lab_config_and_data_layer]]", "[[gps_processing_pipeline]]", "[[data_architecture]]", "[[website_architecture]]", "[[master_task_list]]"]
from_model: claude_cowork
to_model: claude_code
---

# Handoff Brief: Port All Four Engines to Vercel Serverless

## Objective
Port the GPS Stream Processor, Route Grading V3, RPS Engine, Race Readiness Engine, and Anti-Gaming Validator from the Formula Lab (local Python/FastAPI/SQLite) to the production platform (Vercel Python serverless functions + Supabase PostgreSQL).

## Background
The four formula engines exist and work in the Formula Lab at `E:\13 - RMM Fitnes and Route Tracker TESTING\`. They are pure Python with zero external dependencies beyond FastAPI/uvicorn (which are not needed for Vercel). The production website at `THE OFFICIAL BUILD\` currently has zero engine code — the Intelligence pages are static explainers only. The Supabase production database now has all required tables (Gate G4 cleared 2026-04-25): activities, route_analyses, rps_scores, rps_history, athletes, etc.

## Executor
Claude Code — this touches 10+ new files, creates a new `api/python/` directory, and requires careful mathematical fidelity between the Formula Lab engines and the port.

## Brain Context Files
Read these before starting:
- [[formula_lab_engine_files]] — Complete documentation of all four engines, every method, every return value
- [[formula_lab_architecture_overview]] — Formula Lab project structure, dependencies, setup
- [[formula_lab_config_and_data_layer]] — Complete config attribute reference (every env var), SQLite schema
- [[gps_processing_pipeline]] — The 10-step webhook pipeline
- [[data_architecture]] — GeoJSON vs Supabase data split
- [[website_architecture]] — Production tech stack, CLAUDE.md rules, what is and isn't allowed

## Repo Files

### Source (Formula Lab — READ ONLY, do not edit)
- `E:\13 - RMM Fitnes and Route Tracker TESTING\backend\gps_processor.py` — GPS Stream Processor
- `E:\13 - RMM Fitnes and Route Tracker TESTING\backend\route_grader.py` — Route Grading V3
- `E:\13 - RMM Fitnes and Route Tracker TESTING\backend\rps_engine.py` — RPS Engine
- `E:\13 - RMM Fitnes and Route Tracker TESTING\backend\race_readiness.py` — Race Readiness
- `E:\13 - RMM Fitnes and Route Tracker TESTING\backend\anti_gaming.py` — Anti-Gaming Validator
- `E:\13 - RMM Fitnes and Route Tracker TESTING\backend\config.py` — Config system
- `E:\13 - RMM Fitnes and Route Tracker TESTING\backend\dem_lookup.py` — DEM elevation (optional infrastructure)
- `E:\13 - RMM Fitnes and Route Tracker TESTING\.env.example` — All env var names

### Target (Production — WRITE HERE)
- `THE OFFICIAL BUILD\api\` — Vercel serverless functions directory

## Specifications

### Architecture Decision: Python on Vercel
Vercel supports Python serverless functions natively. The engines stay in Python — DO NOT rewrite to JavaScript. The engine logic must be mathematically identical to the Formula Lab. Only the I/O layer changes:
- FastAPI → Vercel Python handler format (`from http.server import BaseHTTPRequestHandler`)
- SQLite reads → Supabase REST API reads (via `urllib.request`, no external deps)
- SQLite writes → Supabase REST API writes
- `config.py` reading `.env` → reading `os.environ` (Vercel injects env vars directly)

### File Structure to Create
```
THE OFFICIAL BUILD/
├── api/
│   ├── config.js                    ← EXISTS, do not touch
│   ├── subscribe.js                 ← EXISTS, do not touch
│   └── python/
│       ├── requirements.txt         ← empty or minimal (prefer stdlib only)
│       ├── config.py                ← Config class, reads os.environ
│       ├── supabase.py              ← Supabase REST client (urllib.request, no SDK)
│       ├── gps_processor.py         ← Direct port, identical logic
│       ├── route_grader.py          ← Direct port, identical logic
│       ├── rps_engine.py            ← Direct port, identical logic
│       ├── race_readiness.py        ← Direct port, identical logic
│       ├── anti_gaming.py           ← Direct port, identical logic
│       ├── dem_lookup.py            ← Port, but make DEM optional (graceful fallback)
│       ├── upload.py                ← Vercel handler: POST /api/python/upload
│       ├── calculate_rps.py         ← Vercel handler: POST /api/python/calculate-rps
│       ├── race_readiness_check.py  ← Vercel handler: GET /api/python/race-readiness
│       └── recalculate_decay.py     ← Vercel handler: POST /api/python/recalculate-decay (cron)
```

### Vercel Python Handler Format
```python
from http.server import BaseHTTPRequestHandler
import json

class handler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = json.loads(self.rfile.read(content_length))
        
        # ... process ...
        
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(result).encode())
```

### Supabase REST Client (supabase.py)
Build a minimal client using `urllib.request` (no external deps). Pattern:
```python
import os, json, urllib.request

SUPABASE_URL = os.environ['SUPABASE_URL']
SUPABASE_SERVICE_KEY = os.environ['SUPABASE_SERVICE_ROLE_KEY']

def query(table, select='*', filters=None):
    url = f"{SUPABASE_URL}/rest/v1/{table}?select={select}"
    if filters:
        for f in filters:
            url += f"&{f}"
    req = urllib.request.Request(url, headers={
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
        'Content-Type': 'application/json'
    })
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())

def insert(table, data):
    url = f"{SUPABASE_URL}/rest/v1/{table}"
    req = urllib.request.Request(url, data=json.dumps(data).encode(), headers={
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }, method='POST')
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())

def upsert(table, data, on_conflict):
    # Same as insert but with Prefer: resolution=merge-duplicates
    ...

def update(table, data, filters):
    # PATCH to /rest/v1/{table}?{filters}
    ...
```

### Config System
Port `config.py` to read from `os.environ` instead of `dotenv`. Every env var name stays identical. Missing vars should raise clear errors. The complete env var list is in [[formula_lab_config_and_data_layer]].

### API Endpoints to Build

**POST /api/python/upload**
- Accepts: `multipart/form-data` with GPX file, `activity_type`, `purpose`, `athlete_id`
- Pipeline: parse_gpx → anti_gaming.validate → save to activities table → grade_route → save to route_analyses → return activity + grade data
- Must store `raw_data` (full gps_processor output) as JSONB in activities table
- Must store `raw_gpx` (original GPX string) for re-processing
- Must denormalise `distance_km`, `elevation_gain_m`, `duration_seconds`, `moving_time_seconds` to activities columns
- Flag severity routing: suppress → store but exclude from scoring. review → store, include provisionally. clean → store normally.

**POST /api/python/calculate-rps**
- Accepts: JSON `{ athlete_id, activity_type?, reference_date? }`
- Loads all training activities for athlete from Supabase
- Runs RPSEngine.calculate_rps() or calculate_all_layers()
- Upserts result to rps_scores table (one row per athlete per discipline)
- Inserts snapshot to rps_history table
- Returns full RPS breakdown

**GET /api/python/race-readiness**
- Accepts: query params `route_id`, `athlete_id`
- Loads route activity + grade from Supabase
- Loads athlete training activities from Supabase
- Runs RaceReadiness.assess_readiness()
- Returns verdict + all five checks

**POST /api/python/recalculate-decay** (future cron)
- For each active athlete: recalculate RPS with today as reference date
- Update rps_scores, insert rps_history
- Log to processing_log table

### Environment Variables to Add to Vercel
All Formula Lab env vars need to be added to Vercel dashboard. The complete list is in `.env.example` in the Formula Lab repo and documented exhaustively in [[formula_lab_config_and_data_layer]]. Current Vercel env vars (7) remain untouched.

### DEM Elevation
DEM lookup requires SRTM .hgt files which won't be on Vercel's filesystem. Two options:
1. Skip DEM for now — use GPS altitude with smoothing (set `dem_corrected: false`)
2. Future: use a cloud elevation API (Google Maps Elevation API — cost consideration noted in [[gps_processing_pipeline]])

For this port: implement option 1. The `dem_lookup.py` should gracefully return None/fallback when no SRTM data is available. The GPS processor already handles this path.

### vercel.json Updates
Add URL rewrites for the new Python endpoints. Do NOT modify existing rewrites.

## Acceptance Criteria
1. All four engine files exist in `api/python/` with logic mathematically identical to Formula Lab
2. `POST /api/python/upload` accepts a GPX file and returns activity + grade data, stored in Supabase
3. `POST /api/python/calculate-rps` returns a valid RPS score breakdown, stored in Supabase
4. `GET /api/python/race-readiness` returns a valid 5-check assessment
5. All endpoints use Supabase REST API (no SDK, no npm/pip dependencies beyond stdlib)
6. Config reads from `os.environ` with clear error messages for missing vars
7. Anti-gaming flags are applied on upload and stored in the activity record
8. DEM gracefully falls back to GPS altitude when SRTM data is unavailable
9. No changes to existing files (`api/config.js`, `api/subscribe.js`, any page HTML, any CSS, any JS in `scripts/`)
10. `vercel.json` updated with new rewrites only (existing rewrites untouched)

## Do NOT
- Do NOT rewrite engines to JavaScript — Python on Vercel is the locked decision
- Do NOT install any pip packages — use Python stdlib only (math, xml, json, urllib, os, uuid, datetime, struct, pathlib)
- Do NOT modify any existing files in the production repo
- Do NOT expose formula values in any API response (Secrecy Rule — [[formula_lab_architecture_overview]] section 10)
- Do NOT use the Supabase JS SDK or Python SDK — raw REST API only
- Do NOT change any formula logic, weights, thresholds, or calculations — port exactly as-is
- Do NOT implement Strava/Garmin OAuth in this handoff — that's a separate task
