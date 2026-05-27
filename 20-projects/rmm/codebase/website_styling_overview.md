---
title: website_styling_overview
domain: rmm
type: knowledge
status: active
created: 2026-04-21
updated: 2026-05-11
updated_by: claude_cowork
tags: [codebase, css, design, styling, overview]
supersedes: ""
related: ["[[website_styling_patterns_and_animations]]", "[[colour_pallet]]", "[[typography]]", "[[website_architecture]]", "[[animation_system]]", "[[website_component_map]]"]
---

# Website Styling — CSS, Colour, Typography

---

## 1. CSS Approach

**Vanilla CSS. No framework. No preprocessor. No build step.**

| What it is NOT | What it is |
|---|---|
| No Tailwind | Four plain `.css` files |
| No Bootstrap | CSS custom properties for tokens |
| No CSS Modules | Page-scoped class naming by convention |
| No Sass/Less | `@media` queries directly in each file |
| No CSS-in-JS | Linked via `<link>` in HTML `<head>` |

### File Structure

| File | Scope | Status |
|---|---|---|
| [styles/components.css](styles/components.css) | CSS variables, nav, footer, shared section shells, page headers, badges | **Active — loaded by every page** |
| [styles/pages.css](styles/pages.css) | All page-specific styles: about, dashboard, shop, product, intelligence, leaderboards, event, legal | **Active — loaded by all pages except map** |
| [styles/map.css](styles/map.css) | Map container, Mapbox control overrides, filter sidebar, email overlay, route popup, pulse dot, cluster markers | **Active — loaded by map and dashboard** |
| ~~[styles/main.css](styles/main.css)~~ | ~~Legacy curtain/landing page styles~~ | **Deleted 2026-04-30** (commit `35b6a56`) |

### Load Pattern

Every page loads `components.css`. Pages with content (not the map) also load `pages.css`. The map and dashboard load `map.css`. No page loads `main.css`.

```
Every page:        components.css
Content pages:     components.css + pages.css
Map page:          components.css + map.css
Dashboard:         components.css + pages.css + map.css
```

### Class Naming Convention

No strict naming methodology (no BEM). Classes are prefixed by section context and written descriptively:

| Prefix | Where used |
|---|---|
| `.site-*`, `.nav-*`, `.footer-*` | Shared layout (components.css) |
| `.page-*`, `.section-*` | Shared page shells (components.css) |
| `.about-*` | About page (pages.css) |
| `.dash-*` | Dashboard (pages.css) |
| `.intel-*` | Intelligence hub (pages.css) |
| `.product-*` | Product and shop pages (pages.css) |
| `.event-*` | Event detail page (pages.css) |
| `.rg-*` | Route grading tool page (pages.css) — added 2026-05-11 |
| `.rps-page-*` | RPS deep-dive page (pages.css) — added 2026-05-11 |
| `.leaderboard-*` | Leaderboards page (pages.css) |
| `.legal-*` | Legal pages (pages.css) |
| `.nav-dropdown`, `.nav-dropdown-*` | Intelligence nav dropdown (components.css) — added 2026-05-11 |
| `.rmm-overlay-*` | Email signup overlay (map.css) |
| `.rmm-filter-*` | Filter sidebar panel, toggle button, sections, rows (map.css) |
| `.rmm-toggle`, `.rmm-toggle-*` | Toggle switch component (map.css) |
| `.rmm-route-*` | Route popup (map.css) |
| `.rmm-clusters-hidden` | Hides DOM cluster markers when routes filter is off (map.css) |
| `.mapboxgl-ctrl-*` | Overridden Mapbox controls (map.css) |

---


## 2. Colour System

### Live Production Variables

Defined in [styles/components.css](styles/components.css) `:root` block. These are the only variables used across the live site.

```css
:root {
    --color-dark:   #171A14;              /* Dark olive — primary background and text */
    --color-light:  #FFF1D4;              /* Papaya / warm cream — page background */
    --color-white:  #FFFFFF;              /* Pure white */
    --color-accent: #FF4E50;              /* Coral red — CTAs, active states, alerts */
    --color-muted:  rgba(23, 26, 20, 0.5);/* 50% dark olive — secondary text, placeholders */
    --font-mono:    'Space Mono', monospace;
    --nav-height:   64px;
}
```

### Colour Usage Map

| Variable | Used for |
|---|---|
| `--color-dark` (`#171A14`) | Nav background, footer background, page header background, dark section backgrounds, text on light backgrounds |
| `--color-light` (`#FFF1D4`) | Page background (`body`, `.page-shell`), card backgrounds in overlay |
| `--color-white` (`#FFFFFF`) | Text on dark backgrounds, icon fills |
| `--color-accent` (`#FF4E50`) | Active nav link, hover states, CTA buttons, accent borders, coming-soon badge, route lines on map, grade A colour, NOT YET verdict, error messages |
| `--color-muted` | Secondary text, descriptions, placeholder labels, border colours |

### Extended Palette (Hardcoded — Not in Variables)

These colours appear in [styles/pages.css](styles/pages.css) and [styles/map.css](styles/map.css) for semantic contexts that don't yet have variables.

| Hex | Name / Role | Where used |
|---|---|---|
| `#C8553D` | Terracotta | Table `thead` backgrounds, legal `h2` headings, legal draft notice border, verdict NOT YET border in about page |
| `#4A7C59` | Forest green | Verdict READY border (`about-verdict-ready`) |
| `#4A7B4A` | Forest green | Verdict READY label text (`verdict-ready`) |
| `#c49a2a` | Amber | Verdict CLOSE border (`about-verdict-close`) |
| `#D4A017` | Gold | Verdict CLOSE label text + Grade C colour |
| `#D4732A` | Dark orange | Grade B colour |
| `#6B8F4A` | Olive green | Grade D colour |
| `#4A7B6B` | Teal | Grade E colour |
| `#2A2D26` | Dark warm grey | (Referenced in orphaned main.css only) |
| `#6B6B5E` | Muted olive | (Referenced in orphaned main.css only) |
| `#1e2419` | Deep dark olive | Nav control hover, fog high-color in map.js |
| `#6b7560` | Medium muted | Overlay eyebrow, error helper, map popup |
| `#a8b09e` | Light muted | Overlay body text, success text |
| `#F5ECD7` | Warm off-white | Map label halos, route popup stats |
| `#ddd5c3` | Warm light border | About table cell borders |

### Orphaned Variable Set (main.css — Not in Use)

[styles/main.css](styles/main.css) defines a second `:root` with semantic names that diverge from the production set. These are not used by any live page.

```css
:root {
    --dark-olive: #171A14;    /* same as --color-dark */
    --papaya:     #FFF1D4;    /* same as --color-light */
    --sunset:     #FF4E50;    /* same as --color-accent */
    --terracotta: #C8553D;    /* not in production variables */
    --muted-olive: #6B6B5E;   /* not in production variables */
    --warm-grey:  #2A2D26;    /* not in production variables */
}
```

**If a curtain/landing page is reintroduced**, these variable names would need to be reconciled with the production set in `components.css`.

### Dark Sections (No Dark Mode — Manual Inversion)

The site has no `prefers-color-scheme` dark mode. Dark regions are explicit HTML sections with `background: var(--color-dark)` and white text applied per-element. Examples:
- Site nav: `background: var(--color-dark)` with white text
- Site footer: same
- Page headers (`.page-header`): same
- Intelligence tool sections (`.intel-tool-section`): same
- Map container: always dark canvas

---


## 3. Typography

### Typeface

**A single typeface is used for the entire site: Space Mono.**

No serif, no sans-serif fallback in practice. The `monospace` generic is the final fallback but should never be visible if the font loads.

```css
--font-mono: 'Space Mono', monospace;
```

**Loading:** Via Google Fonts CDN `<link>` tags in the `<head>` of every HTML page:
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Space+Mono:ital,wght@0,400;0,700;1,400&display=swap" rel="stylesheet">
```

**Weights loaded:** 400 (regular), 700 (bold), and 400 italic. No 700 italic loaded.

**Font smoothing** (set on `html` in `main.css`):
```css
-webkit-font-smoothing: antialiased;
-moz-osx-font-smoothing: grayscale;
```

**Base size:** `16px` set on `html`. All other sizes use `rem` (relative to 16px) or hardcoded `px` in a few legacy spots.

### Type Scale

The scale is not a strict system — sizes are chosen per-use-case. Common sizes in `rem` with their pixel equivalents:

| `rem` | `px` | Where used |
|---|---|---|
| `0.5rem` | 8px | Smallest map preview placeholder text |
| `0.55rem` | 8.8px | Page header label, smallest stat labels |
| `0.6rem` | 9.6px | Coming-soon badge, footer legal, event grade badge, panel titles |
| `0.65rem` | 10.4px | Section label (`--label` pattern), admin nav label |
| `0.7rem` | 11.2px | Breadcrumbs, product spec, event stat, routes table header |
| `0.72rem` | 11.52px | Legal draft notice, overlay consent label |
| `0.75rem` | 12px | Nav link, footer links, section body, about table body |
| `0.78rem` | 12.48px | Legal table body |
| `0.8rem` | 12.8px | Body text on most pages, dashboard activity name |
| `0.82rem` | 13.12px | Overlay body, overlay field input |
| `0.85rem` | 13.6px | Section body, product name, nav brand, event desc |
| `0.875rem` | 14px | Legal page body text |
| `0.9rem` | 14.4px | Verdict label, about grade example, about founder role |
| `0.95rem` | 15.2px | Legal h2, privacy content, about intro body (`1.15rem`) |
| `1.1rem` | 17.6px | About closing tagline, verdict label |
| `1.25rem` | 20px | Product price, product page responsive title |
| `1.3rem` | 20.8px | Page header title |
| `1.4rem` | 22.4px | Event name |
| `1.5rem` | 24px | Section heading, product page title |
| `2rem` | 32px | Grade letter in grade cards |
| `22px` | 22px | Brand name (hardcoded, orphaned main.css) |

### Letter Spacing

Extensive use of letter-spacing, especially for uppercase labels:

| Value | Where |
|---|---|
| `0.03em` | Footer legal text |
| `0.05em` | Various small labels |
| `0.1em` | Nav links (uppercase), section labels |
| `0.12em` | Panel titles, admin nav label |
| `0.15em` | Nav brand name |
| `0.2em` | Section label (`.section-label`), page header label |

### Line Height

| Value | Context |
|---|---|
| `1.3` | Headings |
| `1.5` | Card descriptions, compact body |
| `1.6` | Standard body text |
| `1.65` | Legal draft notice |
| `1.7` | Long-form prose (about, legal, event descriptions) |

### Text Transform

`text-transform: uppercase` is used for all label-class elements, nav links, footer links, CTAs, coming-soon badge, panel titles, table headers.

---


## 7. Dark Mode / Theming

**There is no dark mode implementation.**

No `@media (prefers-color-scheme: dark)` queries exist anywhere in the CSS. No toggle. No theme system.

The site uses a **fixed design**: papaya (`#FFF1D4`) background with dark olive (`#171A14`) text, and hardcoded dark sections inline. Dark regions (nav, footer, map, page headers, intelligence sections) are styled as explicit HTML sections, not as theme states.

The Mapbox map itself is always rendered in dark style (the custom Studio style is dark-terrain themed). This is fixed — the map has no light mode variant.

**Future dark mode:** If ever introduced, the primary change would be in [styles/components.css](styles/components.css) swapping `--color-dark` and `--color-light` values under a `prefers-color-scheme: dark` block, plus targeted overrides for hardcoded colours in [styles/pages.css](styles/pages.css). The map layer would need a separate light Mapbox Studio style.

---


## 8. Known Inconsistencies

These divergences exist in the current codebase. Document here so AI models don't replicate them.

| Issue | Location | Detail |
|---|---|---|
| **Two `:root` variable sets** | `components.css` vs `main.css` | Production uses `--color-dark`, `--color-light`, `--color-accent`. Orphaned `main.css` uses `--dark-olive`, `--papaya`, `--sunset`. Both reference the same hex values. |
| **Hardcoded colours in pages.css** | Grade colours, verdict colours, terracotta | `#C8553D`, `#D4732A`, `#D4A017`, `#6B8F4A`, `#4A7B6B`, `#4A7B4A` are not in the CSS variable set. They should ideally become variables. |
| **font-family not always via variable** | `pages.css` | Many elements in pages.css declare `font-family: 'Space Mono', monospace` directly instead of `var(--font-mono)`. Functionally identical, but inconsistent. |
| **Hardcoded hex in pages.css** | `.about-grade-example`, `.legal-draft-notice`, etc. | Some elements use `#171A14` and `#FF4E50` directly rather than the CSS variables. |
| **`.map-container` in pages.css** | pages.css L6 | A `.map-container` class is defined in pages.css (a placeholder from an earlier iteration) but the live map uses `#map-container` (ID selector) defined in map.css. The pages.css class is never applied. |
