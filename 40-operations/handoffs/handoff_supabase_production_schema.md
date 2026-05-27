---
title: handoff_supabase_production_schema
domain: rmm
type: handoff
status: complete
created: 2026-04-25
updated: 2026-04-25
updated_by: claude_cowork
tags: [handoff, supabase, schema, database]
supersedes: ""
related: ["[[data_architecture]]", "[[master_task_list]]", "[[formula_lab_config_and_data_layer]]", "[[website_data_flow]]", "[[gps_processing_pipeline]]"]
from_model: claude_cowork
to_model: valken_direct
---

# Handoff: Supabase Production Schema

## Objective
Build all production Supabase tables for Run Mad Maps — 15 new tables covering map features, athletes, activities, scoring, events, leaderboards, shop, notifications, and system logging.

## Background
Task #26 on the master task list (Gate G4). The production site currently has only 2 Supabase tables (subscribers, style_config). The full schema is needed to unblock V2 engine ports, admin dashboard, and event system. Schema was architected in a Cowork session on 2026-04-25.

## Execution Method
Direct SQL execution by Valken in Supabase SQL Editor. Three migration scripts produced:
1. `01_rmm_schema_core.sql` — Trigger function, features, fire_zones, performance_zones, products, processing_log
2. `02_rmm_schema_athletes.sql` — Athletes, activities, route_analyses, rps_scores, rps_history, summits, zone_completions, notifications
3. `03_rmm_schema_events.sql` — Events, event_entries, event_results, leaderboard_records, RLS policies

## Design Principles
- `jsonb metadata` column on every table — future fields without migrations
- `text` over `enum` everywhere — new values without ALTER TYPE
- `uuid` primary keys throughout
- Auto-updating `updated_at` via shared trigger function
- Foreign keys use ON DELETE RESTRICT by default (no accidental cascades)
- RLS enabled on all tables with public read where appropriate
- Service role key bypasses RLS for serverless writes
- Partial unique index for source dedup (only when source_activity_id is not null)

## Acceptance Criteria
- All 3 scripts run without error in Supabase SQL Editor
- `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name` returns 17 tables
- Existing subscribers and style_config tables are untouched
- RLS is enabled on all new tables

## Tables Created (15)
features, fire_zones, performance_zones, products, processing_log, athletes, activities, route_analyses, rps_scores, rps_history, summits, zone_completions, notifications, events, event_entries, event_results, leaderboard_records
