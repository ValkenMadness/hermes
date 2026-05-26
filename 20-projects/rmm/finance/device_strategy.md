---
title: device_strategy
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-23
updated_by: valken
tags: [finance, devices, hardware]
supersedes: ""
related: ["[[financial_tracking_and_cost_monitoring]]", "[[phased_build_plan]]"]
---

A bespoke handheld trail running companion — positioned against Garmin but with character, Cape Peninsula specificity, and deep RMM data integration. Distant evolution. Build sequence: prove scoring, partnerships, web/mobile, device.

**Hardware Stack (V1 Prototype):** Raspberry Pi Zero 2W (~$15), Pimoroni HyperPixel 4.0 Touch (4-inch IPS), PiSugar 3 battery, touch + physical buttons, 3D printed enclosure.

**Architecture:** The device is another client of the same API. Three-layer architecture: RMM backend API, Web/mobile frontend, Handheld device (offline-capable lightweight client). Everything built for web automatically ports to device. Scoring formulas stay server-side.

**SD Card Distribution:** Base card ships with device. Updated cards via membership tiers. All proprietary logic stays server-side.
