---
title: map_intro_animation
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [product, map, animation]
supersedes: ""
related: ["[[animation_system]]", "[[map_build_sequence]]"]
---

1. Map loads at Peninsula overview — full Peninsula visible, slight camera tilt. (Instant)
2. RMM logo overlay fades in. (0.5s)
3. Logo holds. (1.5s)
4. Logo fades out. (0.8s)
5. Camera animates — fly to athlete's home region if logged in, stays at Peninsula overview if not. (2.5s)
6. Resting state. All markers visible. Interaction enabled.

Toggle: show_intro_animation boolean in athlete's Supabase record.
