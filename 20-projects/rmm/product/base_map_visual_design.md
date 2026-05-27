---
title: base_map_visual_design
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [product, map, design]
supersedes: ""
related: ["[[colour_pallet]]", "[[map_build_sequence]]", "[[animation_system]]", "[[fire_and_safety_zones]]", "[[65_named_peninsula_peaks]]", "[[map_system_overview]]", "[[map_system_terrain_layers]]", "[[marker_render_states]]"]
---

**Terrain and Topography:** Dark near-black base (#171A14 territory). 3D terrain from initialisation — non-negotiable. Hillshade for directional shadow. Contour lines visible but restrained. Camera with slight pitch. Fog and atmosphere via map.setFog().

**Road and Trail Network:** Freeways thin and low-contrast. Jeep tracks with distinct dash pattern. Trails differentiated by surface type. All RMM route lines use line-z-offset to follow 3D terrain. Route lines grade-colour-coded A–F. Line weights admin-configurable via style_config. All route layers use interpolate expressions for line width — never fixed values.

**Labels:** All default Mapbox POI labels suppressed. Place names at appropriate zoom only. All labels driven by RMM data. Halo treatment: #F5ECD7 at 3px width.

**Map UI Controls:** Zoom controls, compass/bearing, layer toggles (collapsed by default), map legend/key (toggle button), region selector (quick fly-to). All controls use brand palette: Dark Olive background, White text, Sunset Orange for active states.
