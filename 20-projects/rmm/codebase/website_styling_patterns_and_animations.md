---
title: website_styling_patterns_and_animations
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-04-30
updated_by: claude_cowork
tags: [codebase, css, responsive, animations, components]
supersedes: ""
related: ["[[website_styling_overview]]", "[[animation_system]]", "[[website_component_map]]"]
---

# Website Styling — Responsive, Animations, Component Patterns

---

## 4. Responsive Design

### Breakpoints

Two breakpoints only, both max-width:

| Breakpoint | Value | What it handles |
|---|---|---|
| Tablet | `max-width: 768px` | Hamburger nav, multi-column → single column, map panel height, event card simplification |
| Phone | `max-width: 480px` | Padding reductions, font size reductions, further grid collapses, overlay bottom-sheet |

No `min-width` (mobile-first) queries. All breakpoints are max-width (desktop-first — defaults are desktop layout, overrides downgrade for smaller screens).

### Mobile Nav Behaviour

```css
/* Default (desktop): toggle hidden, links visible */
.nav-toggle { display: none; }
.nav-links  { display: flex; }

/* 768px: toggle shown, links hidden until toggled */
@media (max-width: 768px) {
    .nav-toggle { display: flex; }
    .nav-links  { display: none; position: absolute; top: var(--nav-height); ... }
    .nav-links.open { display: flex; }
}
```

Toggle state managed by JavaScript (`classList.toggle('open')` in [scripts/components.js](scripts/components.js)). The hamburger animates to an X via CSS transforms on the three `<span>` bars.

### Grid Collapse Patterns

| Grid | Desktop | 768px | 480px |
|---|---|---|---|
| Systems grid (about) | 2-col | 1-col | — |
| Shop grid | 2-col | 1-col | — |
| Product layout | 2-col | 1-col | — |
| Product related | 3-col | 2-col | 1-col |
| Dashboard row 1 | map 1.3fr + events 1fr | 1-col | — |
| Dashboard row 3 | 3-col | 1-col | — |
| Dashboard row 4 | 2-col | 1-col | — |
| Event layout | 2-col | 1-col | — |
| Intelligence features | 3-col | 1-col | — |
| Intelligence tool columns | 2-col | 1-col | — |
| Component/Grade/Checks grid | 3-col | 2-col | 1-col |
| Leaderboard types | 3-col | 1-col | — |
| Levels strip | flex-row | flex-column | — |
| Verdicts strip | flex-row | flex-column | — |

### Layout Widths

| Container | Max-width |
|---|---|
| Nav inner, footer inner, dashboard, page headers | `1200px` |
| Section content, intelligence pages, intelligence grids | `960px` |
| Product page, event page | `1060px` |
| Legal content | `760px` |
| Legal index | `640px` |
| Privacy content | `640px` |

All containers use `margin: 0 auto` for centring and `padding: 0 1.5rem` (or `3rem 1.5rem` / `4rem 1.5rem` for sections) to keep content off screen edges.

### Map Responsiveness

```css
/* Full-page map: top offset matches nav height */
#map-container {
    position: fixed;
    top: var(--nav-height, 64px);
    left: 0; right: 0; bottom: 0;
}

/* Email overlay: bottom-sheet on phones */
@media (max-width: 480px) {
    .rmm-overlay-backdrop { align-items: flex-end; }
    .rmm-overlay-card { border-radius: 16px 16px 0 0; width: 100%; }
}

/* Map controls: nudge in on mobile */
@media (max-width: 768px) {
    .mapboxgl-ctrl-top-right { top: 8px; right: 8px; }
}
```

---


## 5. Animation System

### CSS Animations

**`@keyframes fadeIn`** — defined in [styles/main.css](styles/main.css) (orphaned file):

```css
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(8px); }
    to   { opacity: 1; transform: translateY(0); }
}
```

Usage (also in orphaned `main.css`): staggered entrance for the curtain landing page:
- Logo area: `animation: fadeIn 0.6s 0.2s forwards`
- Tagline: `animation: fadeIn 0.6s 0.5s forwards`
- Form area: `animation: fadeIn 0.6s 0.8s forwards`
- Footer line: `animation: fadeIn 0.6s 1.1s forwards`

Elements start `opacity: 0` (invisible) and fade-slide upward 8px into position. The `forwards` fill mode keeps the final state after animation ends. **This animation is not visible on the live site** — `main.css` is not loaded.

### CSS Transitions

All active and used in production:

| Element | Property | Duration / Easing |
|---|---|---|
| Nav links (`.nav-link`) | `color` | `0.2s ease` |
| Footer links | `color` | `0.2s ease` |
| Dashboard panel link | `color` | `0.2s ease` |
| Product card link hover | `transform` (translateY −2px lift) | `0.2s ease` |
| Product thumb | `border-color` | `0.2s ease` |
| Product CTA button | `background` | `0.2s ease` |
| Intelligence buttons (`.intel-btn`) | `all` | `0.2s ease` |
| Dashboard buttons (`.dash-btn`) | `all` | `0.2s ease` |
| Form inputs (name row, email row) | `border-color` | `0.2s` |
| Admin nav links | `color` | `0.2s ease` |
| Nav hamburger bars | `all` | `0.3s ease` |
| Footer legal links | `color` | `0.2s` |
| Breadcrumb links | `color` | `0.2s ease` |
| Overlay submit button | (no transition defined) | — |
| Mapbox control buttons (`.mapboxgl-ctrl-group button`) | (no transition defined) | — |

### JS-Driven Animations

These live in [scripts/map.js](scripts/map.js):

| Animation | Mechanism | Duration / Speed |
|---|---|---|
| **Route pulse dot** | `mapboxgl.Marker` + `setTimeout` loop | Per-step delay = `max(16ms, dist / PX_PER_MS)` where `PX_PER_MS = 0.08` (~80 px/s, zoom-independent); loops continuously |
| **Cluster parent shrink** (CSS transition on inner) | `.rmm-cluster-primary-wrap.is-expanded .rmm-cluster-primary { transform: scale(...) }` | `240ms cubic-bezier(0.4, 0, 0.2, 1)` |
| **Cluster secondary fan-in** (CSS keyframe) | `@keyframes rmm-cluster-secondary-in` with per-index `animation-delay` | `220ms cubic-bezier(0.34, 1.56, 0.64, 1)` with 30 ms stagger per child |
| **Cluster zoom-scale tracking** (DOM marker parity with GL singletons) | JS `map.on('zoom', syncClusterScale)` writes `--rmm-cluster-scale` on `<html>` | Reactive — re-syncs on every zoom event |
| **Camera ease-to** (style_config override) | `map.easeTo()` | `duration: 1500ms`, `essential: true` |
| **Marker T3 hover swap** | `map.setFilter()` — instant, no transition | Instant |
| **Route highlight on hover** | `map.setFilter()` + `map.setPaintProperty()` | Instant |
| **Email overlay dismiss** | `classList.add('hidden')` → `display: none` | Instant |
| **Overlay success auto-dismiss** | `setTimeout(dismissOverlay, 2000)` | 2 second delay then instant |

**Intro animation:** Not yet implemented (Stage 4 of the map build plan).

### Hover Effects Summary

| Element | Hover effect |
|---|---|
| Nav/footer links | `color → --color-accent` |
| Product card link | `translateY(-2px)` lift |
| Product thumb | `border-color` darkens |
| Intelligence buttons | Background fill changes |
| Dashboard buttons | `border-color` and `color → --color-accent` |
| Overlay submit | `background: #e83d3f` (darker red) |
| Mapbox nav controls | `background: #1f2219` |
| Overlay dismiss | `color: #6b7560` (lighter muted) |
| Nav toggle (hamburger) | CSS transforms bars → X |
| Map cursor on features | `cursor: pointer` (via `map.getCanvas().style.cursor`) |

---


## 6. Component Styling Patterns

The site uses a small set of repeating visual patterns. Understanding these prevents inconsistency when building new sections.

### Pattern 1: Border Card

The most common component pattern. A faint border on a semi-transparent white background.

```css
border: 1px solid rgba(23, 26, 20, 0.12–0.15);
background: rgba(255, 255, 255, 0.4–0.6);
```

Used for: system cards (about), shop product cards, dashboard panels, event cards, feature cards, intelligence grids, grade cards, check cards, verdict cards, leaderboard type cards.

### Pattern 2: Section Label → Heading → Body

The standard content block. Tiny uppercase spaced label sits above the main heading.

```css
.section-label {
    font-size: 0.65rem;
    letter-spacing: 0.2em;
    text-transform: uppercase;
    color: var(--color-muted);
}

.section-heading {
    font-size: 1.5rem;
    font-weight: 700;
}

.section-body {
    font-size: 0.85rem;
    line-height: 1.7;
}
```

Used for: every content section on every page.

### Pattern 3: Dark Section

Full-width dark-background block with white text, used to visually separate major sections.

```css
background: var(--color-dark);  /* #171A14 */
color: var(--color-white);
```

Used for: site nav, site footer, page headers (`.page-header`), intelligence tool sections (`.intel-tool-section`).

### Pattern 4: Alt Section

Barely-there alternate background for visual rhythm between sections.

```css
background: rgba(23, 26, 20, 0.04);
```

Used for: `.about-problem`, `.about-peninsula`, `.section-alt` on intelligence sub-pages.

### Pattern 5: Spec / Stat Row

A flex row with label left, value right, separated by a bottom border. Used for scannable key-value data.

```css
display: flex;
justify-content: space-between;
padding: 0.6–0.65rem 0;
border-bottom: 1px solid rgba(23, 26, 20, 0.08);
```

Used for: product specs, event stats, event tier pricing.

### Pattern 6: Accent Left Border

A 3px coloured left border signals a verdict or status category.

```css
border-left: 3px solid [colour];
background: rgba([colour-rgb], 0.06);
padding: 0.75rem 1rem;
```

Colours used:
- READY: `#4a7c59` (green)
- CLOSE: `#c49a2a` (amber)
- NOT YET: `#C8553D` (terracotta)
- Legal draft notice: `#C8553D`

### Pattern 7: Outline Button

Two button variants, both using border + transparent background. The accent variant shows red; the dark variant shows white.

```css
/* Accent (red outline) */
.intel-btn-accent {
    border: 1px solid var(--color-accent);
    color: var(--color-accent);
    background: transparent;
}
.intel-btn-accent:hover {
    background: var(--color-accent);
    color: var(--color-white);
}

/* Dark (white outline on dark background) */
.intel-btn-dark {
    border: 1px solid rgba(255, 255, 255, 0.25);
    color: var(--color-white);
}
.intel-btn-dark:hover { border-color: var(--color-white); }
```

### Pattern 8: Filled CTA Button

Solid dark background, white text. Hover → accent red fill.

```css
background: var(--color-dark);
color: var(--color-white);
border: none;
/* hover: */
background: var(--color-accent);
```

Used for: product CTA, overlay submit button (red by default).

### Pattern 9: Custom Scrollbar

Ultra-thin 3px scrollbar applied to dashboard scroll regions.

```css
::-webkit-scrollbar { width: 3px; }  /* or height for horizontal */
::-webkit-scrollbar-track { background: rgba(23, 26, 20, 0.03–0.05); }
::-webkit-scrollbar-thumb { background: rgba(23, 26, 20, 0.12–0.15); }
```

Applied to: `.dash-events-scroll` (vertical), `.dash-activity-scroll` (horizontal).

### Pattern 10: Placeholder / Coming-Soon Block

Empty visual blocks used where images or live data will eventually go.

```css
background: rgba(23, 26, 20, 0.06);
border: 1px solid rgba(23, 26, 20, 0.08);
display: flex;
align-items: center;
justify-content: center;
```

Used for: product image areas, event map preview, event profile placeholder, dashboard map previews, activity map previews, intelligence feature image placeholders.

### Pattern 11: Mapbox Control Override

Mapbox GL's default light-theme controls are inverted to match the dark brand.

```css
.mapboxgl-ctrl-group {
    background: #171A14;
    border: 1px solid #2a2e24;
    border-radius: 0;  /* sharp corners match the aesthetic */
    box-shadow: none;
}
.mapboxgl-ctrl-zoom-in .mapboxgl-ctrl-icon,
.mapboxgl-ctrl-zoom-out .mapboxgl-ctrl-icon,
.mapboxgl-ctrl-compass .mapboxgl-ctrl-icon {
    filter: invert(1);  /* white icons */
}
```

### Border Radius Philosophy

The design is intentionally sharp. Minimal rounding:

| Element | Radius |
|---|---|
| Most cards, buttons, panels | `0` (no border-radius) |
| Coming-soon badge | `2px` |
| Overlay form inputs | `6px` |
| Overlay submit button | `6px` |
| Overlay card (desktop) | `12px` |
| Overlay card (mobile, bottom-sheet) | `16px 16px 0 0` |

### Shadow Philosophy

Almost no box-shadows. Only two uses:

| Element | Shadow |
|---|---|
| Route popup `.mapboxgl-popup-content` | `0 4px 20px rgba(0,0,0,0.5)` |
| Pulse dot `.rmm-pulse-dot` | `0 0 12px 4px rgba(255,78,80,0.6), 0 0 24px 8px rgba(255,78,80,0.3)` |

All other depth and separation is achieved through borders and alpha backgrounds, not shadows.

---
