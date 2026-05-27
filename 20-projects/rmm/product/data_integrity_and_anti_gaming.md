---
title: data_integrity_and_anti_gaming
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [product, data-integrity, anti-gaming]
supersedes: ""
related: ["[[the_four_strategic_moats]]", "[[gps_stream_processor]]", "[[data_level_incidents]]"]
---

Ten validation flags run on every activity ingest.

| Flag | Name | Detection |
|------|------|-----------|
| F1 | Activity Type vs GPS Mismatch | Trail declared but ED <5 m/km, or road declared but GPS shows off-road |
| F2 | Impossible Location Jump | >10 km between start coordinates within 30 minutes |
| F3 | Split Activity Detection | Start coordinates within 500m within 2 hours. Exceptions: >30% pace difference; <2km excluded |
| F4 | Linear GPS Trace | Treadmill/stationary detection. Placeholder — needs full lat/lon variance analysis |
| F5 | Speed Anomaly | Speed inconsistent with activity type AND route grade. Thresholds decrease with difficulty class |
| F6 | Leaderboard Source Policy | System architecture rule: leaderboards from events only, never training data |
| F7 | Manual Upload Detection | Strava manual flag, absent upload_id, no device name. Production only |
| F8 | Fabricated GPS Detection | Timestamp regularity CV <0.01, speed variation CV <0.02 on routes >2km |
| F9 | Elevation Yo-Yo Detection | >80 m/km density + >40% coordinate revisiting. Elevation capped at unique route |
| F10 | Short Activity Validation | For Tier 2/3 PC activities: GPS continuity, movement ratio, elapsed-to-distance ratio |

F8 correctly flagged 143 of 150 synthetic activities while passing all 25 real activities clean.
