---
title: data_architecture
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-21
updated_by: claude_cowork
tags: [product, data, architecture, supabase]
supersedes: ""
related: ["[[platform_architecture_and_tech_stack]]", "[[website_data_flow]]", "[[popia_compliance]]", "[[data_decisions]]", "[[gps_processing_pipeline]]", "[[oauth_and_api_compliance]]", "[[trail_ecosystem_design]]"]
---

Geographic truth for peaks and caves lives in GeoJSON files. Routes and POIs have migrated to Supabase as the source of truth — managed via admin tools (Trail Library, POI Manager) and served to the map via API endpoints. The map joins all sources at load time.

### GeoJSON Files (Static Geographic Layer)

| File | Contents | Update Trigger |
|------|----------|---------------|
| peaks.geojson | Name, coordinates, elevation, region, notes | New peak / coordinate corrected |
| caves.geojson | Name, coordinates, elevation, region, notes | New cave / coordinate corrected |
| regions.geojson | Region boundary polygons | Boundary adjusted |
| zones.geojson | Zone boundary polygons, zone type | Zone created / adjusted |
| overlays.geojson | Coordinate anchor, zoom threshold, overlay slug | New illustration |
| events.geojson | Event start coordinate, event ID | New event location |

**Note:** `routes.geojson` and `pois.geojson` are no longer used. Routes are now managed via the Trail Library admin tool and served from Supabase via `/api/python/trails?action=routes`. POIs are managed via the POI Manager admin tool and served via `/api/python/pois?action=map-data`.

### Supabase Tables (Operational + Geographic Layer)

**trails table:** id (uuid PK), name (text), slug (text, unique), status (draft|live|archived), event_type (trail|time_trial|hill_climb|hill_bomb), grade (A–F), grade_display (text), tds (integer 1–10), total_distance_km (numeric), total_elevation_gain (numeric), total_elevation_loss (numeric), elevation_density (numeric), min_elevation (numeric), max_elevation (numeric), effort_descriptor (text), road_percentage (numeric), trail_percentage (numeric), climb_count (integer), coordinates_json (jsonb — full GPS LineString), elevation_profile (jsonb — distance/elevation points), composite_grade (jsonb — climb/descent grade breakdowns), description (text), seasonal_start (date), seasonal_end (date), show_on_map (boolean), include_in_readiness (boolean), athlete_id (uuid FK), created_at, updated_at.

**trail_segments table:** id (uuid PK), trail_id (uuid FK → trails), segment_index (integer), segment_type (climb|descent), km_start (numeric), km_end (numeric), distance_km (numeric), elevation_gain (numeric), elevation_loss (numeric), gradient_avg (numeric), grade (A–F), tds (integer), dds (integer), terrain_type (trail|road|mixed), notes (text), tags (text[]), created_at.

**trail_pois table:** id (uuid PK), name (text), category (text — 14 categories: waterfall, stream_crossing, info_board, viewpoint, parking, gate, water_source, danger, rest_area, bridge, rock_formation, shelter, trailhead, photo_spot), latitude (numeric), longitude (numeric), elevation (numeric), description (text), created_at, updated_at.

**trail_poi_links table:** trail_id (uuid FK → trails), poi_id (uuid FK → trail_pois), km_position (numeric — where on the trail the POI sits), composite PK (trail_id, poi_id). Junction table enabling many-to-many trail↔POI associations.

**features table:** id (uuid PK), feature_name (text — joins to GeoJSON), feature_type (peak|cave|route|event|poi|zone), tier (1|2|3), icon_s1–s4 (text), animation_state, sprite_ref, is_live (boolean), live_from/until (timestamp), seasonal_from/until (text MM-DD), video_url, product_page_url, newsletter_prompt (boolean), subscription_gate (null|basic|premium), grade (A–F, routes only), is_visible (boolean), updated_at.

**athletes table:** id (uuid PK), display_name, region, rps_score (numeric 0–100), rps_level, subscription_tier (free|basic|premium), show_intro_animation (boolean, default true), created_at.

**Other tables:** summits, fire_zones, performance_zones, zone_completions, style_config, subscribers, users, route_analyses, rps_scores, rps_history.

### Error States and Loading

- **Supabase loading:** Map renders with GeoJSON immediately. Supabase state loads asynchronously. Markers appear at T1 first, upgrade when data arrives.
- **Supabase unreachable:** Map continues with GeoJSON-only rendering. Full graceful degradation.
- **Missing icon:** Falls back to generic category icon. Never broken image.
- **GeoJSON failure:** Error state with retry button.
- **Mapbox token failure:** Branded error page. No raw errors exposed.
