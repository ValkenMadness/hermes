---
title: poi_system_reference
domain: rmm
type: knowledge
status: active
created: 2026-05-21
updated: 2026-05-21
updated_by: claude_cowork
tags: [codebase, poi, map, admin]
supersedes: ""
related: ["[[website_component_map]]", "[[website_key_files]]", "[[map_system_overview]]", "[[trail_ecosystem_design]]", "[[data_architecture]]"]
---

# POI System Reference

Points of Interest (POIs) are geographic markers on the RMM map representing trail features like waterfalls, viewpoints, parking areas, and trailheads. They are managed by admins via the POI Manager and displayed on the public map and trail detail pages.

---

## 1. POI Categories

14 categories are supported. Each has a unique SVG icon in two tiers (T1 at 24px, T2 at 32px).

| Category Key | Display Label | Icon Files |
|---|---|---|
| `waterfall` | Waterfall | `t1-poi-waterfall.svg`, `t2-poi-waterfall.svg` |
| `stream_crossing` | Stream Crossing | `t1-poi-stream-crossing.svg`, `t2-poi-stream-crossing.svg` |
| `info_board` | Info Board | `t1-poi-info-board.svg`, `t2-poi-info-board.svg` |
| `viewpoint` | Viewpoint | `t1-poi-viewpoint.svg`, `t2-poi-viewpoint.svg` |
| `parking` | Parking | `t1-poi-parking.svg`, `t2-poi-parking.svg` |
| `gate` | Gate / Entrance | `t1-poi-gate.svg`, `t2-poi-gate.svg` |
| `water_source` | Water Source | `t1-poi-water-source.svg`, `t2-poi-water-source.svg` |
| `danger` | Danger / Warning | `t1-poi-danger.svg`, `t2-poi-danger.svg` |
| `rest_area` | Rest Area | `t1-poi-rest-area.svg`, `t2-poi-rest-area.svg` |
| `bridge` | Bridge | `t1-poi-bridge.svg`, `t2-poi-bridge.svg` |
| `rock_formation` | Rock Formation | `t1-poi-rock-formation.svg`, `t2-poi-rock-formation.svg` |
| `shelter` | Shelter / Hut | `t1-poi-shelter.svg`, `t2-poi-shelter.svg` |
| `trailhead` | Trailhead | `t1-poi-trailhead.svg`, `t2-poi-trailhead.svg` |
| `photo_spot` | Photo Spot | `t1-poi-photo-spot.svg`, `t2-poi-photo-spot.svg` |

**Icon directory:** `/public/icons/pois/`

**Icon naming convention:** `t[tier]-poi-[category-slug].svg` where the category slug uses hyphens (not underscores) — e.g. `stream_crossing` category → `stream-crossing` in the filename.

---

## 2. Database Schema

### `trail_pois` table

| Column | Type | Purpose |
|---|---|---|
| `id` | uuid PK | Auto-generated |
| `name` | text | POI display name |
| `category` | text | One of the 14 category keys |
| `latitude` | numeric | Decimal latitude |
| `longitude` | numeric | Decimal longitude |
| `elevation` | numeric | Elevation in metres (optional) |
| `description` | text | Free-text description (optional) |
| `created_at` | timestamp | Auto-set |
| `updated_at` | timestamp | Auto-set |

### `trail_poi_links` table (junction)

| Column | Type | Purpose |
|---|---|---|
| `trail_id` | uuid FK → trails | The trail this POI is linked to |
| `poi_id` | uuid FK → trail_pois | The POI being linked |
| `km_position` | numeric | Where on the trail (in km) the POI sits |

Composite primary key: `(trail_id, poi_id)`. A POI can be linked to multiple trails, and a trail can have multiple POIs.

---

## 3. API Endpoints

All POI endpoints route through `/api/python/trails.py` via a Vercel rewrite (`/api/python/pois` → `/api/python/trails`). The `?action=` parameter determines the operation.

| Action | Method | Auth | Purpose |
|---|---|---|---|
| `list` | GET | Admin | Returns all POIs for the admin library table |
| `map-data` | GET | None | Returns POI GeoJSON FeatureCollection for map rendering |
| `create` | POST | Admin | Creates a new POI |
| `update` | POST | Admin | Edits an existing POI |
| `delete` | POST | Admin | Deletes a POI (and removes all trail_poi_links) |

**Trail-POI association endpoints** (on the trails action namespace):

| Action | Method | Auth | Purpose |
|---|---|---|---|
| `link-poi` | POST | Admin | Associates a POI with a trail at a km position |
| `unlink-poi` | POST | Admin | Removes a POI association from a trail |
| `trail-pois&trail_id=X` | GET | Admin | Lists all POIs linked to a specific trail |

---

## 4. Map Rendering

POIs are rendered on the public map as Mapbox GL layers.

**Icon loading:** All 28 SVG icons (14 categories × 2 tiers) are fetched, rasterised to canvas ImageData, and registered with `map.addImage()` during the icon loading phase.

**Layers per category:** Each POI category gets two layers:
- Base layer: shows T1 icon below zoom 13, T2 icon at zoom 13+
- Hover layer: shows on mouseenter for interaction feedback

**Data source:** POIs are fetched from `/api/python/pois?action=map-data` which returns a GeoJSON FeatureCollection. This is added as a single Mapbox source, with per-category layers filtered by `['==', ['get', 'category'], 'category_key']`.

**Popup:** On hover, shows a simplified popup with POI name and category. Follows the same pattern as peak/cave popups.

**Filter sidebar:** POI layers are toggled as a group via the filter sidebar. The "POIs" toggle controls visibility of all POI category layers.

---

## 5. Admin Workflow (POI Manager)

**Page:** `/intelligence/poi-manager` (admin-gated)
**Files:** `pages/intelligence-poi-manager.html`, `scripts/poi-manager.js`

### Create Flow
1. Admin fills form: name, category (dropdown), latitude, longitude, elevation, description
2. Coordinates support DDM (Degrees Decimal Minutes) format: e.g. `S 34° 5.328' E 18° 24.662'` — auto-parsed to decimal on input
3. Submit → POST to `/api/python/pois?action=create`
4. Library table refreshes

### Edit Flow
1. Click edit icon on library table row
2. Form populates with existing values
3. Submit → POST to `/api/python/pois?action=update`
4. Library table refreshes

### Delete Flow
1. Click delete icon on library table row
2. Confirmation dialog
3. POST to `/api/python/pois?action=delete`
4. Library table refreshes (also removes all trail_poi_links)

### Map Preview
"View on Map" button opens a Mapbox modal showing the POI's location with a marker pin.

---

## 6. Trail-POI Associations

POIs can be linked to trails via the Trail Library segment editor. Each association includes a `km_position` indicating where along the trail the POI is located.

**UI location:** Trail Library → click "Segments" on a trail → segment editor modal shows a POI association section at the bottom.

**Display on trail detail page:** Linked POIs appear at the bottom of the `/trail/:slug` page with their category icon, name, category label, km position, and elevation.

---

## 7. Adding a New POI Category

To add a new category:
1. Create two SVG icons: `t1-poi-[slug].svg` (24×24) and `t2-poi-[slug].svg` (32×32) in `/public/icons/pois/`
2. Add the category to `POI_CATEGORIES` in `scripts/poi-manager.js` and `scripts/trail-detail.js`
3. Add the category to the icon loading array in `scripts/map.js`
4. The API accepts any category string — no backend changes needed
