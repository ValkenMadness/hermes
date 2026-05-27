---
title: gps_processing_pipeline
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [operations, gps, pipeline]
supersedes: ""
related: ["[[gps_stream_processor]]", "[[data_architecture]]", "[[formula_lab_engine_files]]"]
---

The core data pipeline — the most critical automated system.

**Trigger:** Strava/Garmin webhook on activity completion.

**Pipeline:**
1. Webhook received → validate authenticity
2. Fetch full activity data via API
3. Run GPS Stream Processor
4. Run anti-gaming flags (F1–F10)
5. If "suppress" severity → exclude from scoring, store with flag
6. If "review" severity → include provisionally, queue for V's review
7. If clean → store activity, recalculate RPS
8. If level band boundary crossed → trigger notification
9. Update race readiness for target events
10. Log processing time, quality flags, errors

**Failure handling:** API rate limit → queue with exponential backoff. DEM lookup failure → GPS altitude fallback, flag for re-processing. Webhook failure → idempotent processing. Processing error → log context, store raw data, alert V.

**Cost consideration:** Google Maps Elevation API charges per request. Batch requests (512 locations per request) reduce cost. At 100 athletes × 4 activities/week = ~2,000 API calls/week. Monitor and set billing alerts.
