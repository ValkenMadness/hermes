---
title: animation_system
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [product, animation, ux]
supersedes: ""
related: ["[[map_intro_animation]]", "[[marker_render_states]]", "[[website_styling_overview]]", "[[asset_pipeline]]", "[[base_map_visual_design]]", "[[website_styling_patterns_and_animations]]"]
---

Six animation states. Any marker switched between states via admin without code deploy.

| State | Trigger | Method | Switched Via |
|-------|---------|--------|-------------|
| STATIC | Default | Symbol layer PNG | Admin |
| LOOP | Continuous | Sprite sheet in symbol layer | Admin |
| HOVER | Cursor enter / tap | HTML Marker + CSS | Admin |
| SEASONAL | Annual date window | Supabase seasonal_from/until | Admin sets dates |
| EVENT-LIVE | Event is live | Supabase is_live field | Admin toggles |
| CONDITIONAL | Athlete completion | Supabase athlete record | Automatic |
